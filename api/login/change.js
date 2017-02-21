var auth = require('server/auth.js');
var restify = require('restify');

module.exports.handler = function(req, res, next) {

    var trusted_auth = auth.get(req.params.auth.token);

    if (!trusted_auth)
        return next(new restify.NotAuthorizedError('Valid auth token required.'));
    if (!req.params.new_password)
        return next(new restify.InvalidArgumentError('New password required.'));

    return auth.change_password(trusted_auth.id, req.params.new_password, res);
};