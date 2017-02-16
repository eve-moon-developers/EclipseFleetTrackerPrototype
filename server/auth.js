//Module Variables
const NodeCache = require("node-cache");

const AuthCache = new NodeCache({
    stdTTL: 86400,
    checkperiod: 60
});

const IDCache = new NodeCache({
    stdTTL: 86400 * 2,
    checkperiod: 60
});

const crypto = require('crypto');
const bcrypt = require('bcrypt-nodejs');
const util = require('util');

module.exports.start_auth = function() {
    console.log("Booting auth system...");

    //Insert the dev token.
    if (true) {
        AuthCache.set("dev-auth-token", {
            "valid": true,
            "ident": "MOON Developer",
            "id": 1,
            "rank": 100,
            "token": "dev-auth-token"
        });
    }
};

module.exports.get = function(token) {
    var auth = AuthCache.get(token);
    if (auth === undefined) {
        return auth;
    } else {
        //Now we need to handle updating the database.
        //This includes revoking permissions and bullshit like that.
        return auth;
    }
}

module.exports.expire = function(user_id) {

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