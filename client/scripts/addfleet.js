function loadadd() {
    nav.button_add.prop("disabled", true);
    if (templates.addfleet) {
        content_div.html(templates.addfleet);

        $("#submit-fleet-button").click(function () { tryAddFleet(); })

    } else {
        content_div.html("<h4>Loading data...</h4>");
        load_div.load("templates/addfleet.template", function (data) {
            console.log("Loaded addfleet template: \n" + data);
            templates.addfleet = data;
            loadadd();
        });
    }
}

function tryAddFleet() {

}