module.exports.register = function() {
    console.log("Adding routes...");

    var server = require("server/content.js").server;

    server.get('/api/login/get', require('api/login/get.js').handler);
    server.get('/api/login/check', require('api/login/check.js').handler);
    server.get('/api/fleet/categories', require('api/fleet/categories.js').handler);
    server.post('/api/fleet/create', require('api/fleet/create.js').handler);
    server.post('/api/fleet/update', require('api/fleet/update.js').handler);
    server.get('/api/fleet/basic', require('api/fleet/basic.js').handler);
    server.get('/api/fleet/listing', require('api/fleet/listing.js').handler);
    server.get('/api/fleet/details', require('api/fleet/details.js').handler);
    server.post('/api/fleet/delete', require('api/fleet/delete.js').handler);
    server.get('/api/fleet/checkpoint_details', require('api/fleet/checkpoint_details.js').handler);
    server.get('/api/members/listing', require('api/members/listing.js').handler);
    server.get('/api/util/random_members', require('api/util/random_members.js').handler);
}