const pg = require('pg');
const restify = require('restify');
const util = require('util');


module.exports.bootstrap_pg = function(testComplete) {
    console.log("Bootstrapping database.");
    //console.log("User: " + process.env.PGUSER);
    //console.log("PW: " + process.env.PGPASSWORD);
    //console.log("DB: " + process.env.PGDATABASE);
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

    ft.pg.pool.connect(function(err, client, done) {
        if (err) {
            console.error('error fetching client from pool', err);
            return;
        }
        client.query('SELECT $1::int AS number', ['1'], function(err, result) {
            //call `done()` to release the client back to the pool 
            done();

            if (err) {
                console.error('error running query', err);
                return;
            } else if (result.rows[0].number != 1) {
                console.error('invalid server response.');
                return;
            } else {
                console.log("Database connected.");
                testComplete();
            }
        });
    });

    global.fleettool.pg.restQuery = function(query, req, res, next, callback) {
        var ft = global.fleettool;
        console.log("Running query: ");
        console.log(query);
        ft.pg.pool.connect(function(err, client, done) {
            if (err) {
                next(new restify.InternalServerError('Error fetching client from pool', err));
            }

            console.log("Client fetched.");

            client.query(query, function(err, result) {
                //call `done()` to release the client back to the pool 
                done();

                if (err) {
                    next(new restify.InternalServerError('Internal query error. Check console.'));
                    console.log("Query Error: ");
                    console.log(util.inspect(err));
                } else {
                    console.log("Query: " + query);
                    console.log("Result: " + util.inspect(result));
                    return callback(result, req, res, next);
                }
            });
        });
    }
}