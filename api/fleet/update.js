var auth = require('server/auth.js');
var pg_pool = require("server/database").pg_pool;
var util = require('util');
var restify = require('restify');

module.exports.handler = function(req, res, next) {
    if (auth.get(req.params.auth.token) === undefined) {
        res.send({ "valid": false, "msg": "Bad auth token" });
        return next();
    } else {
        var params = req.params;

        console.log("Recieved fleet update request: ");
        params.members = params.members.split("\n");

        console.log(params.members);

        var member_query = "INSERT INTO characters (name) VALUES ( $1 ) ON CONFLICT (name) DO UPDATE SET last_reference=now() at time zone 'utc' RETURNING (character_id)";

        var queries = [];

        for (m of params.members) {
            console.log("Querying: " + m);
            queries.push(pg_pool.query(member_query, [m]));
        }

        var member_ids = [];

        Promise.all(queries).then(values => {
            for (m of values) {
                member_ids.push(m.rows[0].character_id);
            }
            var checkpoint_query = "INSERT INTO checkpoints (fleet_id, creation_time, description) VALUES ($1, now() at time zone 'utc', $2) RETURNING checkpoint_id";
            return pg_pool.query(checkpoint_query, [params.fleet_id, params.notes]);
        }).then(result => {
            var checkpoint_id = result.rows[0].checkpoint_id;
            var queries = [];
            var pap_query = "INSERT INTO paps (character_id, checkpoint_id) VALUES ($1, $2)";
            for (m of member_ids) {
                queries.push(pg_pool.query(pap_query, [m, checkpoint_id]));
            }

            return Promise.all(queries);
        }).then(values => {
            console.log(util.inspect(values));
            res.send("Done.");
            next();
        });
    }
}