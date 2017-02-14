module.exports.handler = function(req, res, next) {
    console.log("Request recieved: " + req.params.username);
    var auth = require('server/auth.js');
    auth.login(req.params).then(function(data) {
        res.send(data);
        return next();
    });
};