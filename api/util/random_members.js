var members = require("member_sample.json");

function getRandomSubarray(arr, size) {
    var shuffled = arr.slice(0),
        i = arr.length,
        min = i - size,
        temp, index;
    while (i-- > min) {
        index = Math.floor((i + 1) * Math.random());
        temp = shuffled[index];
        shuffled[index] = shuffled[i];
        shuffled[i] = temp;
    }
    return shuffled.slice(min);
}

module.exports.handler = function(req, res, next) {
    var output = "";

    var data = getRandomSubarray(members, Math.ceil(5 + Math.random() * 100));

    for (d of data) output += d + "<br>";
    res.end('<html><body>' + output + '</body></html>');
    return next();
}