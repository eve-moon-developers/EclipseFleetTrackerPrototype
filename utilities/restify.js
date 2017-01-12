var restify = require('restify');
var login = require('../endpoints/login.js');
var fleet = require('../endpoints/fleet/fleet.js');

module.exports.bootstrap_rest = function () {

    console.log("Bootstrapping restify.")

    var server = restify.createServer();
    server.use(restify.bodyParser());
    server.use(restify.queryParser());

    server.get("/api/ping", function (req, res, next) {
        res.send("pong");
        return next();
    });

    login.boot_login(server);
    fleet.boot_fleets(server);

    server.get(/.*/, restify.serveStatic({
        directory: 'client',
        default: 'index.html'
    }));

    Object.keys(server.router.mounts).forEach(function(key) {
        var mount = server.router.mounts[key];
        console.log(mount.spec.path + " @ " + mount.spec.method);
    });

    //console.log(server.router.mounts);

    server.listen(process.env.PORT, function () {
        console.log('%s listening at %s', server.name, server.url);
    });
}