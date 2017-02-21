module.exports.register = function() {
    console.log("Adding routes...");

    var server = require("server/content.js").server;

    var endpoints = require("api/routes.json");

    if (process.env.DEBUG_AUTH === "TRUE") {
        //Use require new so that it refreshes the module. These should be non-static anyway.
        var requirenew = require("require-new");
        console.log("Building endpoints using require-new.");
        endpoints.forEach(function(data) {
            console.log("Loading " + data[0] + " endpoint " + data[1]);
            if (data[0] === "get") {
                server.get("/api" + data[1], function(req, res, next) { requirenew("api" + data[1]).handler(req, res, next); });
            } else if (data[0] === "post") {
                server.post("/api" + data[1], function(req, res, next) { requirenew("api" + data[1]).handler(req, res, next); });
            } else {
                console.log("Bad endpoint configuration in route.js.");
                process.exit(-1);
            }
        });
    } else {
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
}