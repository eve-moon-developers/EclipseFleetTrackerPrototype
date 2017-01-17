var crypto = require('crypto');
var bcrypt = require('bcrypt-nodejs');
var pg_escape = require('pg-escape');
var NodeCache = require('node-cache');
var restify = require('restify');
var util = require('util');

var pg = global.fleettool.pg;

const myCache = new NodeCache({
    stdTTL: 86400,
    checkperiod: 60
});

module.exports.boot_login = function(server) {
    server.get("/api/login/check", function(req, res, next) {
        res.send(check_auth(req.params.token));
        return next();
    });

    server.get("/api/login/login", function(req, res, next) {
        //console.log(util.inspect(req));
        try_login(req.params, res, next);
    });
}

module.exports.check_auth = function(auth) {
    return check_auth(auth);
}

check_auth = function(auth) {
    // DEVELOPER AUTH token
    //REMOVE BEFORE PRODUCTION
    if (auth == "wcj" && myCache.get("wcj") == undefined) {
        myCache.set("wcj", {
            username: "wcj",
            id: "1",
            rank: "100"
        });
    }
    return myCache.get(auth);
}

function processLogin(success, creds, res, next, result) {
    if (success) {
        var timeout = 100;
        var token = crypto.randomBytes(64).toString('hex');
        while (myCache.get(token) !== undefined && timeout > 0) {
            token = crypto.randomBytes(64).toString(hex);
            timeout = timeout - 1;
        }

        if (timeout == 0) {
            next(new restify.InternalServerError("Could not generate auth token."));
            return;
        }

        var ident = {};
        ident.username = creds.username;
        ident.id = result.rows[0].id;
        ident.rank = result.rows[0].rank;

        myCache.set(token, ident);

        res.send(token);
        return next();
    } else {
        res.send("");
        return next();
    }
}

function try_login(creds, res, next) {
    var query = pg_escape("SELECT ( hash, rank, id ) FROM logins WHERE username='%s';", creds.username);

    pg.pool.query(query, function(err, result) {
        if (err) {
            return next(new restify.InternalServerError('Login query error.', err));
        } else {
            if (result.rows.length == 0) {
                processLogin(false, creds, res, next, undefined);
            } else if (result.rows.length == 1) {
                var valid = bcrypt.compareSync(escape(creds.password), result.rows[0].hash);
                console.log("Login attempt. User: " + creds.username + " Result: " + valid);

                processLogin(valid, creds, res, next, result);
            } else {
                console.error("Duplicate credentials! Error on username: " + creds.username);
                res.send(new restify.InternalServerError("Login failure. Contact an administrator."));
                return next();
            }
        }
    });
}