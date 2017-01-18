var restify = require('restify');

module.exports.start_content = function() {
    console.log("Booting content server...");

    var server = restify.createServer();
    server.use(restify.bodyParser());
    server.use(restify.queryParser());

    server.get("/api/ping", function(req, res, next) {
        res.send("pong");
        return next();
    });

    module.exports.server = server;
}

module.exports.serve_content = function() {

    var server = module.exports.server;

    server.get("/res/\.*/", restify.serveStatic({
        directory: 'bower_components'
    }));

    server.get("/\.*/", restify.serveStatic({
        directory: 'client',
        default: 'index.html'
    }));

    console.log("Route listing: ");

    Object.keys(server.router.mounts).forEach(function(key) {
        var mount = server.router.mounts[key];
        console.log(mount.spec.path + " @ " + mount.spec.method);
    });

    server.listen(8000, function() {
        console.log("Eclipse Fleet Tracker being served at port 8000");
    });
}