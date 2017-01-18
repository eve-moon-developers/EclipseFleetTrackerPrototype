var util = require('util');

if (process.argv.length != 6) {
    console.log("Incorrect usage. Specify the username, password, and rank you want to add.");
    process.exit(-1);
}

require("server/database.js").start_pg().then(function() {
    var pg_pool = require("server/database.js").pg_pool;
    var bcrypt = require('bcrypt-nodejs');

    var hash = escape(bcrypt.hashSync(process.argv[4], "$2a$10$chwuijqBqqzq7mAPQRB3Vu"));
    console.log("Transmitted hash: '" + hash + "'");
    hash = bcrypt.hashSync(hash, bcrypt.genSaltSync());

    var query = "INSERT INTO logins AS l (username, hash, rank, created) VALUES ('" +
        process.argv[3] + "','" + hash + "','" + process.argv[5] +
        "', now() at time zone 'utc' ) ON CONFLICT (username) DO UPDATE SET hash=EXCLUDED.hash, modified=now() at time zone 'utc' RETURNING modified";

    pg_pool.query(query, function(err, res) {
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