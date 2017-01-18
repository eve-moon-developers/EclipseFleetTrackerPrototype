//Module variables
const pg = require('pg');

var pg_pool;

module.exports.start_pg = function() {
    console.log("Booting Postgres system...");

    var config = {
        user: process.env.PGUSER,
        password: process.env.PGPASSWORD,
        database: process.env.PGDATABASE,
        max: 16,
        host: 'localhost',
        idleTimeoutMillis: 30000
    }

    pg_pool = new pg.Pool(config);

    module.exports.pg_pool = pg_pool;

    return pg_pool.connect().then(function() {
        console.log("Testing Postgres client connection...");
        return (pg_pool.query('SELECT $1::int AS number', ['1']));
    }).then(function(results) {
        if (results.rows.length == 1 && results.rows[0].number == 1) {
            console.log("Client connected successfully!");
        }
    }).catch(e => {
        console.error("Connection error occured!");
        console.error(e.message, e.stack);
        process.exit(-1);
    });
}