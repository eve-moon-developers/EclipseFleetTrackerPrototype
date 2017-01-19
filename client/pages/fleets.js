router.pages["fleets"] = {};

router.pages["fleets"].handler = function() {

    console.log("Loading fleets page...");

    var me = router.pages["fleets"];
    if (me.template === undefined) {
        $.get("templates/view_fleets.html", function(data) {
            me.template = data;
            me.handler();
        });
    } else {
        ft.page.section.body.html(me.template);
        ft.page.section.body.fadeIn();

        router.clear_buttons();
        ft.page.nav.fleets.prop('disabled', true);

        var tdiv = $("#view-fleets-body");

        $.get("/api/fleet/listing", { auth: ft.ident }).then(data => {
            console.log(data);
            var cont = "";
            for (d of data) {
                cont += "<tr>";
                cont += "<td>" + d.title + "</td>";
                cont += "<td>" + d.fc + "</td>";

                if (d.last_updated == null) {
                    cont += "<td>&#x221e;</td>"
                } else {
                    var created = new Date(d.last_updated);
                    console.log(created);
                    var seconds = (Date.now() - created + created.getTimezoneOffset() * 60 * 1000) / 1000;

                    if (seconds < 60) {
                        cont += "<td>" + Math.floor(seconds) + "s</td>";
                    } else if (seconds < 3600) {
                        cont += "<td>" + Math.floor(seconds / 60) + "m</td>";
                    } else if (seconds < 86400) {
                        cont += "<td>" + Math.floor(seconds / 3600) + "h</td>";
                    } else {
                        cont += "<td>" + Math.floor(seconds / 86400) + "d</td>";
                    }
                }

                cont += "<td>-1</td>";
                cont += "<td>" + d.members + "</td>";
                cont += "<td>" + d.checkpoints + "</td>";
                cont += "<td><button onclick=router.load('#update/" + d.id +
                    "')>Update</button></td>";
                cont += "</tr>"
            }
            tdiv.html(cont);
        });
    }
}