module.exports.register = function() {
    console.log("Adding routes...");

    var server = require("server/content.js").server;

    server.get('/api/login/get', require('api/login/get.js').handler);
    server.get('/api/login/check', require('api/login/check.js').handler);
    server.get('/api/fleet/categories', require('api/fleet/categories.js').handler);
}