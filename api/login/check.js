module.exports.handler = function(req, res, next) {
    var auth = require('server/auth.js');
    res.send(auth.get(req.params.token));
};