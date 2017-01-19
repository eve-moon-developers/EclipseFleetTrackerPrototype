var auth = require('server/auth.js');
var pg_pool = require("server/database").pg_pool;

module.exports.handler = function(req, res, next) {
    console.log("Pool handler.");
    if (auth.get(req.params.auth.token) === undefined) {
        res.send({ "valid": false, "msg": "Bad auth token" });
        return next();
    } else {
        pg_pool.query("SELECT * from members_summary ORDER BY  pap_count DESC, fleet_participation DESC").then(function(data) {
            res.send(data.rows);
            console.log("Member listing: " + data.rows.length);
            return next();
        });
    }
};