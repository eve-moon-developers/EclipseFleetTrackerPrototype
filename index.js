var ft_pg = require("./utilities/pg.js");
var ft_rest = require("./utilities/restify.js");

global.fleettool = {};

console.log("Starting Eclipse Fleet Tool Server...");

ft_pg.bootstrap_pg(ft_rest.bootstrap_rest);
