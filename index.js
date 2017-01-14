global.fleettool = {};

if (process.argv[2] === "add-user") {
    require("./utilities/usercmds.js").add_user();
} else if (process.argv[2] === "del-user") {
    require("./utilities/usercmds.js").del_user();
} else if (process.argv[2] === "ls-users") {
    require("./utilities/usercmds.js").ls_users();
} else {
    console.log("Starting Eclipse Fleet Tool Server...");

    require("./utilities/pg.js").bootstrap_pg(function() {
        require("./utilities/restify.js").bootstrap_rest();
    });
}