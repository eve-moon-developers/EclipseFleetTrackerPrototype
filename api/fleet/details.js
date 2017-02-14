var auth = require('server/auth.js');
var pg_pool = require("server/database").pg_pool;

module.exports.handler = function(req, res, next) {
    if (auth.get(req.params.auth.token) === undefined) {
        res.send({ "valid": false, "msg": "Bad auth token" });
        return next();
    } else {
        if (!req.params.fleet_id)
            return next(new restify.InvalidArgumentError('Fleet ID required.'));

        pg_pool.query("SELECT * from fleet_details WHERE id=$1", [req.params.fleet_id]).then(function(data) {
            var package = { "fleet": data.rows[0], checkpoints: [] };
            pg_pool.query("SELECT * from checkpoint_details WHERE fleet_id=$1", [req.params.fleet_id]).then(function(data) {
                package.checkpoints = data.rows;
                res.send(package);
                return next();
            });
        });
    }
};