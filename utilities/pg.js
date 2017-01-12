var pg = require('pg');
var restify = require('restify');
var util = require('util');

module.exports.bootstrap_pg = function (callback) {
    console.log("Bootstrapping database.");
    console.log("User: " + process.env.PGUSER);
    console.log("PW: " + process.env.PGPASSWORD);
    console.log("DB: " + process.env.PGDATABASE);
    //This will add the global variables we need for connecting to pgadmin.
    var ft = global.fleettool;

    var config = {
        user: process.env.PGUSER,
        password: process.env.PGPASSWORD,
        database: process.env.PGDATABASE,
        max: 16,
        host: 'localhost',
        idleTimeoutMillis: 30000
    }

    ft.pg = {};
    ft.pg.pool = new pg.Pool(config);

    ft.pg.pool.connect(function (err, client, done) {
        if (err) {
            return console.error('error fetching client from pool', err);
        }
        client.query('SELECT $1::int AS number', ['1'], function (err, result) {
            //call `done()` to release the client back to the pool 
            done();

            if (err) {
                return console.error('error running query', err);
            } else if (result.rows[0].number != 1) {
                return console.error('invalid server response.');
            } else {
                console.log("Database connected.");
                return callback();
            }
        });
    });

    global.fleettool.pg.restQuery = function(query, req, res, next, callback) {
        var ft = global.fleettool;
        console.log("Running query: ");
        console.log(query);
        ft.pg.pool.connect(function (err, client, done) {
            if (err) {
                next(new restify.InternalServerError('error fetching client from pool', err));
            }

            console.log("Client fetched.");

            client.query(query, function (err, result) {
                //call `done()` to release the client back to the pool 
                done();

                if (err) {
                    next(new restify.InternalServerError('Internal query error. Check console.'));
                    console.log("Query Error: ");
                    console.log(util.inspect(err));
                } else {
                    return callback(result, req, res, next);
                }
            });
        });
    }
}