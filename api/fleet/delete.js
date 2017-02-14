var auth = require('server/auth.js');
var pg_pool = require("server/database").pg_pool;
var util = require('util');
var restify = require('restify');

function delete_fleet(trusted_auth, params, res, next) {
    pg_pool.query("SELECT fleet_id FROM fleets WHERE fleet_id=$1", [params.fleet_id]).then(function(data) {
        if (data.rows.length < 1) {
            return next(new restify.InvalidArgumentError('Invalid Fleet ID specified.'));
        }

        var queries = [];

        queries.push(pg_pool.query("DELETE FROM paps WHERE paps.pap_id IN (SELECT paps.pap_id FROM paps, checkpoints WHERE paps.checkpoint_id=checkpoints.checkpoint_id AND checkpoints.fleet_id = $1)", [params.fleet_id]));
        queries.push(pg_pool.query("DELETE FROM checkpoints WHERE checkpoints.fleet_id = $1", [params.fleet_id]));
        queries.push(pg_pool.query("DELETE FROM fleets WHERE fleet_id = $1", [params.fleet_id]));

        Promise.all(queries).then(values => {
            res.send("Done!");
            return next();
        });
    });
}

module.exports.handler = function(req, res, next) {
    if (!req.params.auth)
        return next(new restify.NotAuthorizedError('Auth token required.'));

    if (!req.params.fleet_id)
        return next(new restify.InvalidArgumentError('Fleet ID required.'));

    var trusted_auth = auth.get(req.params.auth.token);
    if (trusted_auth === undefined) {
        res.send({ "invalid": true, "msg": "Bad auth token" });
        return next();
    } else if (trusted_auth.rank < 10) {
        pg_pool.query("SELECT fleet_id FROM fleets WHERE fleets.fleet_creator=$1", [trusted_auth.id]).then(function(data) {
            if (data.rows.length > 0) {
                delete_fleet(trusted_auth, req.params, res, next);
            }
            res.send({ "invalid": true, "msg": "Not fleet creator or high rank." });
        });
    } else {
        delete_fleet(trusted_auth, req.params, res, next);
    }
}