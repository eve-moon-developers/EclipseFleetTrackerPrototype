module.exports.boot_fleets = function(server) {
    server.post('/api/fleet/add/', require('./addFleet.js').addFleet);
}