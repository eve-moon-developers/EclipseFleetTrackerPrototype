var auth = require('server/auth.js');
var pg_pool = require("server/database").pg_pool;
var util = require('util');
var restify = require('restify');

function create_fleet(trusted_auth, params, res, next) {
    if (!params.auth)
        return next(new restify.NotAuthorizedError('Auth token required.'));

    if (!params.auth.id)
        return next(new restify.NotAuthorizedError('User ID required.'));

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
        var checkpoint_query = "INSERT INTO checkpoints (fleet_id, creation_time, description, creator) VALUES ($1, now() at time zone 'utc', $2, $3) RETURNING checkpoint_id";
        return pg_pool.query(checkpoint_query, [params.fleet_id, params.notes, trusted_auth.id]);
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

module.exports.handler = function(req, res, next) {
    var trusted_auth = auth.get(req.params.auth.token);
    if (trusted_auth === undefined) {
        res.send({ "invalid": true, "msg": "Bad auth token" });
        return next();
    } else if (trusted_auth.rank < 5) {
        pg_pool.query("SELECT fleet_id FROM fleets WHERE fleets.fleet_creator=$1", [trusted_auth.id]).then(function(data) {
            if (data.rows.length > 0) {
                create_fleet(trusted_auth, req.params, res, next);
            }
            res.send({ "invalid": true, "msg": "Not fleet creator or high rank." });
        });
    } else {
        create_fleet(trusted_auth, req.params, res, next);
    }
}