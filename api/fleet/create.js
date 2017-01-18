var auth = require('server/auth.js');
var pg_pool = require("server/database.js").pg_pool;
var util = require('util');
var restify = require('restify');

module.exports.handler = function(req, res, next) {
    if (auth.get(req.params.auth.token) === undefined) {
        res.send({ "valid": false, "msg": "Bad auth token" });
        return next();
    } else {
        var params = req.params;

        console.log("Recieved fleet add request: ");
        console.log(util.inspect(params));

        if (!params.auth)
            return next(new restify.NotAuthorizedError('Auth token required.'));

        if (!params.auth.id)
            return next(new restify.NotAuthorizedError('User ID required.'));

        if (!params.fc)
            return next(new restify.InvalidArgumentError("FC Required."));

        if (!params.title)
            return next(new restify.InvalidArgumentError("Title Required."));

        if (!params.importance)
            return next(new restify.InvalidArgumentError("Importance Required."));

        console.log("Add fleet meets requirements.");

        var fc_query = "INSERT INTO characters (name) VALUES ( $1 ) ON CONFLICT (name) DO UPDATE SET last_reference=now() at time zone 'utc' RETURNING (character_id)";
        pg_pool.query(fc_query, [params.fc]).then(function(result) {
            var fleet_query = "INSERT INTO fleets (fc_character_id, title, fleet_type, description, composition, update_time, fleet_creator) VALUES ( $1, $2, $3, $4, $5, now() at time zone 'utc', $6) RETURNING (fleet_id)";
            return pg_pool.query(fleet_query, [result.rows[0].character_id, params.title, params.importance, params.description, params.composition, params.auth.user_id]);
        }).then(function(result) {
            console.log(util.inspect(result));
            res.send({ "valid": true, "id": result.rows[0].fleet_id });
            return next();
        });
    }
};