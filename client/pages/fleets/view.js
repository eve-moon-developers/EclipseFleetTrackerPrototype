router.pages["fleets/view"] = {};

router.pages["fleets/view"].handler = function() {

    console.log("Loading fleet view page...");
    var me = router.pages["fleets/view"];
    if (router.hash.length < 2) {
        router.error_message = "Can not view a non-existant fleet.";
        router.load("#error");
        return;
    }

    if (me.template === undefined) {
        $.get("templates/fleets/view_fleet.html", function(data) {
            me.template = data;
            me.handler();
        });
    } else {
        ft.page.section.body.html(me.template);
        ft.page.section.body.fadeIn();

        router.clear_buttons();

        $.get("/api/fleet/details", { auth: ft.ident, fleet_id: router.hash[1] }, function(data) {
            var options = {
                weekday: "short",
                month: "short",
                day: "numeric",
                hour: "2-digit",
                minute: "2-digit",
                timeZoneName: "short"
            };

            var ct = new Date(data.last_updated);
            ct.setTime(ct.getTime() + ct.getTimezoneOffset() * 60 * 1000);
            $("#fleet").text(data.title);
            $("#fc").text(data.fc);
            $("#upd").text(ct.toLocaleTimeString("en-US", options));
            $("#mbr").text(data.members);
            $("#fleet-desc").text(data.description);
        });
        var tdiv = $("#view-checkpoints-body");
        $.get("/api/fleet/checkpoint_details", { auth: ft.ident, fleet_id: router.hash[1] }).then(data => {
            console.log(data);

            var cont = "";
            for (d of data) {
                var options = {
                    weekday: "short",
                    month: "short",
                    day: "numeric",
                    hour: "2-digit",
                    minute: "2-digit",
                    timeZoneName: "short"
                };
                var offset = new Date().getTimezoneOffset();
                var ct = new Date(d.creation_time);
                ct.setTime(ct.getTime() + ct.getTimezoneOffset() * 60 * 1000);
                cont += "<tr>";
                cont += "<td>" + ct.toLocaleTimeString("en-US", options) + "</td>";
                cont += "<td align='center'>" + d.count + "</td>";
                cont += "<td>" + d.description + "</td>";
                cont += "</tr>";
            }
            tdiv.html(cont);
        });







    }
}