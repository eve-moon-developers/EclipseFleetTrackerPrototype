var auth = require('server/auth.js');
var pg_pool = require("server/database").pg_pool;

module.exports.handler = function(req, res, next) {
    if (auth.get(req.params.auth.token) === undefined) {
        res.send({ "valid": false, "msg": "Bad auth token" });
        return next();
    } else {
        pg_pool.query("SELECT * FROM fleet_categories").then(function(data) {
            res.send(data.rows);
            return next();
        });
    }
};