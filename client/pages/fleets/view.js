router.pages["fleets/view"] = {};

router.pages["fleets/view"].handler = function() {

    console.log("Loading fleet view page...");

    if (router.hash.length < 2) {
        router.error_message = "Can not view a non-existant fleet.";
        router.load("#error");
        return;
    }

    var me = router.pages["fleets/view"];
    if (me.template === undefined) {
        $.get("templates/view_fleet.html", function(data) {
            me.template = data;
            me.handler();
        });
    } else {
        ft.page.section.body.html(me.template);
        ft.page.section.body.fadeIn();

        router.clear_buttons();

        $("#button-delete-fleet").click(function() {
            $("#button-delete-fleet").prop("disabled", true);

            var package = {};

            package.auth = ft.ident;
            package.fleet_id = router.hash[1];

            $.post("/api/fleet/delete", package, function(data) {
                console.log(data);

                if (!alert("Check the console for results.")) {
                    router.load("fleets/list");
                }
            });
        });

        $.get("/api/fleet/details", { auth: ft.ident, fleet_id: router.hash[1] }, function(data) {
            if (!data || data.length === 0) {
                router.error_message = "Can not view a non-existant fleet.";
                router.load("#error");
                return;
            }
            console.log("!!!!!!!!!!!!!!");
            console.log("Fleet data");
            console.log(data);
        });
    }
}