var auth = require('server/auth.js');
var pg_pool = require("server/database").pg_pool;

module.exports.handler = function(req, res, next) {
    if (auth.get(req.params.auth.token) === undefined) {
        res.send({ "valid": false, "msg": "Bad auth token" });
        return next();
    } else {
        pg_pool.query("SELECT * from fleet_summary ORDER BY last_updated DESC LIMIT 25").then(function(data) {
            res.send(data.rows);
            console.log("Fleet listing: " + data.rows.length);
            return next();
        });
    }
};