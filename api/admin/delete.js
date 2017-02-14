var auth = require('server/auth.js');
var pg_pool = require("server/database").pg_pool;
var util = require('util');
var restify = require('restify');

function delete_user(user_id, res, next) {
    pg_pool.query("DELETE FROM logins WHERE id=$1", [user_id]).then(data => {
        res.send(data);
        auth.expire(user_id);
        return next();
    });
}

module.exports.handler = function(req, res, next) {
    if (!req.params.auth)
        return next(new restify.NotAuthorizedError('Auth token required.'));

    if (!req.params.user_id)
        return next(new restify.InvalidArgumentError('User ID required.'));

    var trusted_auth = auth.get(req.params.auth.token);
    if (trusted_auth === undefined) {
        return next(new restify.NotAuthorizedError('Bad auth token.'));
        return next();
    } else if (trusted_auth.rank < 10) {
        return next(new restify.NotAuthorizedError('Insufficient Permissions.'));
    } else {
        pg_pool.query("SELECT rank FROM logins WHERE id=$1", [req.params.user_id]).then(data => {
            if (data.rows.length === 0) {
                return next(new restify.InvalidArgumentError('Bad user id.'));
            } else if (data.rows[0].rank < 10) {
                return next(new restify.InvalidArgumentError('Cannot ban this user.'));
            } else {
                delete_user(req.params.user_id, res, next);
            }
        });
    }
}