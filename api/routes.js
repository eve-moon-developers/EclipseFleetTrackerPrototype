module.exports.register = function() {
    console.log("Adding routes...");

    var server = require("server/content.js").server;

    var endpoints = [
        ["get", "/admin/list"],

        ["post", "/login/get"],
        ["post", "/login/check"],

        ["get", "/fleet/categories"],
        ["get", "/fleet/basic"],
        ["get", "/fleet/listing"],
        ["get", "/fleet/details"],
        ["get", "/fleet/checkpoint_details"],
        ["post", "/fleet/create"],
        ["post", "/fleet/update"],
        ["post", "/fleet/delete"],

        ["get", "/members/listing"],

        ["get", "/util/random_members"]
    ];

    endpoints.forEach(function(data) {
        console.log("Loading " + data[0] + " endpoint " + data[1]);
        if (data[0] === "get") {
            server.get("/api" + data[1], require("api" + data[1]).handler);
        } else if (data[0] === "post") {
            server.post("/api" + data[1], require("api" + data[1]).handler);
        } else {
            console.log("Bad endpoint configuration in route.js.");
            process.exit(-1);
        }
    });
}