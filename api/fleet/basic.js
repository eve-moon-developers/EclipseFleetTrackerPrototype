var auth = require('server/auth.js');
var pg_pool = require("server/database").pg_pool;

module.exports.handler = function(req, res, next) {
    if (auth.get(req.params.auth.token) === undefined) {
        res.send({ "valid": false, "msg": "Bad auth token" });
        return next();
    } else if (req.params.fleet_id === undefined) {
        res.send({ "valid": false, "msg": "Missing fleet id." });
        return next();
    } else {
        pg_pool.query("SELECT * from basic_fleets WHERE fleet_id=$1", [req.params.fleet_id]).then(function(data) {
            res.send(data.rows[0]);
            return next();
        });
    }
};