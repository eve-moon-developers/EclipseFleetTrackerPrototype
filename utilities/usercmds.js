const util = require('util');

module.exports.add_user = function() {
    if (process.argv.length != 6) {
        console.log("Incorrect usage. Specify the username, password, and rank you want to add.");
        process.exit(-1);
    }

    require("./pg.js").bootstrap_pg(function() {
        var pg = global.fleettool.pg;
        var bcrypt = require('bcrypt-nodejs');

        var hash = escape(bcrypt.hashSync(process.argv[4], "$2a$10$chwuijqBqqzq7mAPQRB3Vu"));
        console.log("Transmitted hash: '" + hash + "'");
        hash = bcrypt.hashSync(hash, bcrypt.genSaltSync());

        var query = "INSERT INTO logins AS l (username, hash, rank, created) VALUES ('" +
            process.argv[3] + "','" + hash + "','" + process.argv[5] +
            "', now() at time zone 'utc' ) ON CONFLICT (username) DO UPDATE SET hash=EXCLUDED.hash, modified=now() at time zone 'utc' RETURNING modified";

        pg.pool.query(query, function(err, res) {
            if (err) {
                console.log("Error: " + err.message);
                console.log(util.inspect(err));
                process.exit(-1);
            } else {
                console.log(util.inspect(res));
                if (res.rows[0] === null) {
                    console.log("User created.");
                } else {
                    console.log("User updated.")
                }
                process.exit(0);
            }
        });
    });
}

module.exports.del_user = function() {
    if (process.argv.length != 4) {
        console.log("Incorrect usage. Specify the username you want to remove only.");
        process.exit(-1);
    }

    require("./pg.js").bootstrap_pg(function() {
        var pg = global.fleettool.pg;

        var query = "DELETE FROM logins WHERE username='" + process.argv[3] + "' returning *";

        pg.pool.query(query, function(err, res) {
            if (err) {
                console.log("Error: " + err.message);
                console.log(util.inspect(err));
                process.exit(-1);
            } else {
                console.log(util.inspect(res));
                if (res.rowCount == 0) {
                    console.log("User " + process.argv[3] + " does not exist.");
                } else {
                    console.log("User " + process.argv[3] + " was deleted in " + res.rowCount + " instances.");

                    console.log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
                    console.log("!!! - WILL NOT TAKE EFFECT UNTIL NODE SERVER RESTARTED !!!");
                    console.log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
                }
                process.exit(0);
            }
        });
    });
}

module.exports.ls_users = function() {

    require("./pg.js").bootstrap_pg(function() {
        var pg = global.fleettool.pg;

        var query = "SELECT * FROM logins ORDER BY username";

        pg.pool.query(query, function(err, res) {
            if (err) {
                console.log("Error: " + err.message);
                console.log(util.inspect(err));
                process.exit(-1);
            } else {
                console.log(util.inspect(res.rows));
                process.exit(0);
            }
        });
    });

}