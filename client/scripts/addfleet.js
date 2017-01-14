function loadadd() {
    nav.button_add.prop("disabled", true);
    if (templates.addfleet) {
        content_div.html(templates.addfleet);

        $("#submit-fleet-add-button").click(function() { tryAddFleet(); })

    } else {
        content_div.html("<h4>Loading data...</h4>");
        load_div.load("templates/addfleet.template", function(data) {
            console.log("Loaded addfleet template: \n" + data);
            templates.addfleet = data;
            loadadd();
        });
    }
}

function tryAddFleet() {
    var package = {};
    package.FC = $("#fcNameInput").val();
    package.Title = $("#fleetTitleInput").val();
    package.Importance = $("#fleetImportanceInput").val();
    package.Description = escape($("#fleetDescriptionInput").val());
    package.Composition = $("#fleetDoctrineInput").val();
    package.Auth = data.token;
    $.post("/api/fleet/add", package, function(data) {
        console.log(data);
    });
}