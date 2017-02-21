console.log("Welcome to the Eclipse Fleet Tracker!");

if (process.argv.length == 2) {
    console.log("No arguments supplied, starting standard server.");

    require("server/database.js").start_pg().then(function() {
        require("server/auth.js").start_auth();
        require("server/content.js").start_content();

        require("api/add_routes.js").register();

        require("server/content.js").serve_content();
    });
} else {
    if (process.argv[2] === "add-user") {
        require("ops/add_user.js");
    } else if (process.argv[2] === "del-user") {
        require("ops/del_user.js");
    } else if (process.argv[2] === "ls-users") {
        require("ops/ls_users.js");
    } else {
        console.log("Invalid argument specified.")
    }
}