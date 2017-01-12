var util = require("util");

var ft = global.fleettool;

module.exports.addFleet = function (req, res, next) {

    var params = req.params;
    params.Members = params.Members.split(/\r?\n/);


    console.log("Recieved fleet add request: ");
    console.log(util.inspect(params));

    convertFC(params, res, next);
};

var restQuery = global.fleettool.pg.restQuery;

function convertFC(params, res, next) {
    //INSERT INTO characters (name) VALUES ( 'Sciencegeek' ) ON CONFLICT (name) DO UPDATE SET name=excluded.name RETURNING (id);
    if (!params.FC) res.send(405, new Error("Fleet must have an FC."));
    var query = "INSERT INTO characters (name) VALUES ( '" + params.FC + "' ) ON CONFLICT (name) DO UPDATE SET name=excluded.name RETURNING (id)";
    restQuery(query, params, res, next, function (result, req, res, next) {
        console.log("FC: " + req.FC + " @ " + result.rows[0].id);
        req.fc_id = result.rows[0].id;
        return convertChars(req, res, next);
    });
}

function convertChars(params, res, next) {
    console.log("Convert details: ");
    console.log(util.inspect(params));
    if (params.Members.length == 0) {
        submitFleet(params, res, next);
    } else {
        if (params.member_ids === undefined) {
            params.member_ids = [];
        }

        var memberToLookup = params.Members.shift();
        console.log("Converting char: " + memberToLookup);

        var query = "INSERT INTO characters (name) VALUES ( '" + memberToLookup + "' ) ON CONFLICT (name) DO UPDATE SET name=excluded.name RETURNING (id)";
        restQuery(query, params, res, next, function (result, req, res, next) {

            console.log(memberToLookup + " @ " + result.rows[0].id);

            req.member_ids.unshift(result.rows[0].id);

            return convertChars(req, res, next);
        });
    }
}

function submitFleet(params, res, next) {
    var query = "INSERT INTO fleets (name, FC, catagory, description) VALUES ('";
    query += params.Title + "', '",
    query += params.fc_id + "', '";
    query += params.Importance + "', '";
    query += params.Description + "') RETURNING (id)"
    restQuery(query, params, res, next, function(result, req, res, next) {
        console.log("Fleet added.");
        submitCharacters(req, res, next);
    });
}

function submitCharacters(params, res, next) {
    
    res.send("Done.");
    return next();
}