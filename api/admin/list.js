var auth = require('server/auth.js');
var pg_pool = require("server/database").pg_pool;
var util = require('util');
var restify = require('restify');

function list_users(res, next) {
    pg_pool.query("SELECT * FROM logins ORDER BY id ASC").then(value => {
        res.send(value.rows);
        next();
    })
}

module.exports.handler = function(req, res, next) {
    if (!req.params.auth)
        return next(new restify.NotAuthorizedError('Auth token required.'));

    var trusted_auth = auth.get(req.params.auth.token);
    if (trusted_auth === undefined) {
        return next(new restify.NotAuthorizedError('Bad auth token.'));
        return next();
    } else if (trusted_auth.rank < 10) {
        return next(new restify.NotAuthorizedError('Insufficient Permissions.'));
    } else {
        list_users(res, next);
    }
}