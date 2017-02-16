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
        $.get("templates/fleets/view_fleet.html", function(data) {
            me.template = data;
            me.handler();
        });
    } else {
        ft.page.section.body.html(me.template);
        ft.page.section.body.fadeIn();

        router.clear_buttons();

        var fleet_details;

        $("#button-delete-fleet").click(function() {
            $("#button-delete-fleet").prop("disabled", true);

            var package = {};

            package.auth = ft.ident;
            package.fleet_id = router.hash[1];

            $.post("/api/fleet/delete", package).done(function(data) {
                ft.modal.setup("Buh bye!", "The fleet \"" + fleet_details.fleet.title + "\" was deleted.<br>Click anywhere grey, or the red X to continue.");
                ft.modal.doShow(true, () => router.load("fleets/list"));
            }).fail(function(xhr, status, error) {
                ft.modal.setup("Fml. That didn't work!", "The server returned:<br><br>" + xhr.responseText + "<br><br>Taking you back to the fleet listing.<br>Click anywhere grey, or the red X to continue.");
                ft.modal.doShow(true, () => router.load("fleets/list"));
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
            fleet_details = data;
        });
    }
}