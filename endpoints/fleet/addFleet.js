const util = require("util");
const restify = require('restify');
const login = require('../login.js');
const async = require('async');

var ft = global.fleettool;

module.exports.addFleet = function(req, res, next) {

    var params = req.params;

    console.log("Recieved fleet add request: ");
    console.log(util.inspect(params));

    if (!params.Auth)
        return next(new restify.NotAuthorizedError('Auth token required.'));

    if (!params.ID)
        return next(new restify.NotAuthorizedError('User ID required.'));

    if (!login.check_auth(params.Auth))
        return next(new restify.NotAuthorizedError('Invalid auth token.'));

    if (!params.FC)
        return next(new restify.InvalidArgumentError("FC Required."));

    if (!params.Title)
        return next(new restify.InvalidArgumentError("Title Required."));

    if (!params.Importance)
        return next(new restify.InvalidArgumentError("Importance Required."));

    console.log("Add fleet meets requirements.");

    var fc_query = "INSERT INTO characters (name) VALUES ( $1 ) ON CONFLICT (name) DO UPDATE SET last_reference=now() at time zone 'utc' RETURNING (character_id)";
    ft.pg.pool.query(fc_query, [params.FC], function(err, result1) {
        if (err) {
            console.log("FC Error: " + util.inspect(err));
            return next(new restify.InternalServerError('Fleet Add - Convert FC query error.', err));
        }

        var fleet_query = "INSERT INTO fleets (fc_character_id, title, fleet_type, description, composition, update_time, fleet_creator) VALUES ( $1, $2, $3, $4, $5, now() at time zone 'utc', $6) RETURNING (fleet_id)";
        ft.pg.pool.query(fleet_query, [result1.rows[0].character_id, params.Title, params.Importance, params.Description, params.Composition, params.ID], function(err, results2) {
            if (err) {
                console.log("Add Fleet Error: " + util.inspect(err));
                return next(new restify.InternalServerError('Fleet Add - Fleet query error.', err));
            }

            res.send({ fleet_id: results2.rows[0].fleet_id });
            return next();
        });
    });
};