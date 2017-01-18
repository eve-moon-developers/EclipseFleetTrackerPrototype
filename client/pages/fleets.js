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
                cont += "<td>-1</td>";
                cont += "<td>" + d.members + "</td>";
                cont += "<td>" + d.checkpoints + "</td>";
                cont += "<td><button onclick=router.load('#view/" + d.id +
                    "')>View</button></td>";
                cont += "</tr>"
            }
            tdiv.html(cont);
        });
    }
}