console.log("Welcome to the Eclipse Fleet Tracker!");

if (process.argv.length == 2) {
    console.log("No arguments supplied, starting standard server.");

    require("server/database.js").start_pg().then(function() {
        require("server/auth.js").start_auth();
        require("server/content.js").start_content();

        require("api/routes.js").register();

        require("server/content.js").serve_content();
    });
}