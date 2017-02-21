//Module Variables
const NodeCache = require("node-cache");
const crypto = require('crypto');
const bcrypt = require('bcrypt-nodejs');
const util = require('util');
const pg_pool = require("server/database.js").pg_pool;
const restify = require('restify');

const AuthCache = new NodeCache({
    stdTTL: 86400,
    checkperiod: 60
});

const IDCache = new NodeCache({
    stdTTL: 86400 * 2,
    checkperiod: 60
});

module.exports.start_auth = function() {
    console.log("Booting auth system...");

    //Insert the dev token.
    if (process.env.DEBUG_AUTH === "TRUE") {
        AuthCache.set("dev-auth-token", {
            "valid": true,
            "ident": "MOON Developer",
            "id": 0,
            "rank": 10,
            "token": "dev-auth-token"
        }, 0);
        IDCache.set(0, "dev-auth-token");
    }
};

module.exports.get = function(token) {
    return AuthCache.get(token);
}

module.exports.expire = function(user_id) {

    if (user_id === 1 && process.env.DEBUG_AUTH === "TRUE") {
        return;
    }

    var token = IDCache.get(user_id);
    IDCache.del(user_id);
    AuthCache.del(token);
}

module.exports.expire_all = function() {
    AuthCache.flushAll();
}

module.exports.change_password = function(user_id, new_password, res) {
    module.exports.expire(user_id);
    //Insert the dev token.
    if (process.env.DEBUG_AUTH === "TRUE") {
        AuthCache.set("dev-auth-token", {
            "valid": true,
            "ident": "MOON Developer",
            "id": 1,
            "rank": 10,
            "token": "dev-auth-token"
        });
        IDCache.set(1, "dev-auth-token");
    }

    new_password = bcrypt.hashSync(escape(new_password), bcrypt.genSaltSync());

    return pg_pool.query("UPDATE logins SET hash=$1, modified=now() at time zone 'utc' WHERE id=$2", [new_password, user_id]).then(data => res.send("Done.")).catch(function(error) {
        res.send(new restify.InternalServerError(error));
        console.log("Error updating login: ");
        console.log(util.inspect(error));
    });
}

module.exports.login = function(auth) {
    var username = auth.username;
    var password = auth.password;

    var pg_pool = require("server/database.js").pg_pool;

    return pg_pool.query("SELECT hash, rank, id FROM logins WHERE username=$1", [username]).then(res => {
        if (res.rows.length == 0) {
            return {
                "valid": false
            };
        } else if (res.rows.length > 1) {
            return {
                "valid": false,
                "error": "More than one user row found. Contact an administrator immediately."
            }
        } else {
            var valid = bcrypt.compareSync(escape(password), res.rows[0].hash);

            if (!valid) {
                console.log("Rejected login attempt.");
                return { "valid": false };
            } else {
                console.log("Accepted login attempt.");
                var ret = {
                    "valid": true,
                    "ident": username,
                    "id": res.rows[0].id,
                    "rank": res.rows[0].rank
                };

                var token = crypto.randomBytes(64).toString('hex');
                while (AuthCache.get(token) !== undefined) {
                    token = crypto.randomBytes(64).toString(hex);
                }

                ret.token = token;

                AuthCache.set(token, ret);
                if (IDCache.get(ret.id)) {
                    AuthCache.del(IDCache.get(ret.id));
                }
                IDCache.set(ret.id, token);

                return pg_pool.query("UPDATE logins SET last_login=now() at time zone 'utc' WHERE id=$1", [ret.id]).then(res => {
                    return ret;
                })

            }
        }
    });
}