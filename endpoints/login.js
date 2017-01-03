var LruSet = require("collections/lru-set");
var crypto = require('crypto');

module.exports.boot_login = function (server) {
    server.get("/api/login/check", function (req, res, next) {
        res.send(check_auth(req.query.token));
        return next();
    });

    server.get("/api/login/login", function (req, res, next) {
        res.send(check_login(req.query));
        console.log(req);
        return next();
    });
}

module.exports.check_auth = function (auth) {
    return check_auth(auth);
}

var valid_creds = new LruSet({}, 100);

function check_auth(auth) {
    return valid_creds.has(auth);
}

function check_login(creds) {
    if (creds.user === "eclipse" && creds.pass === "helloworld") {
        var id = crypto.randomBytes(20).toString('hex');
        valid_creds.add(id);
        return id;
    } else {
        return "null";
    }
}