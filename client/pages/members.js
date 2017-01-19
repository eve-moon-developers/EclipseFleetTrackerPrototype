router.pages["members"] = {};

router.pages["members"].handler = function() {

    console.log("Loading members page...");

    var me = router.pages["members"];
    if (me.template === undefined) {
        $.get("templates/view_members.html", function(data) {
            me.template = data;
            me.handler();
        });
    } else {
        ft.page.section.body.html(me.template);
        ft.page.section.body.fadeIn();

        router.clear_buttons();
        ft.page.nav.members.prop('disabled', true);

        var tdiv = $("#view-members-body");

        $.get("/api/members/listing", { auth: ft.ident }).then(data => {
            console.log(data);
            var cont = "";
            for (d of data) {
                cont += "<tr>";
                cont += "<td>" + d.name + "</td>";
                cont += "<td>" + d.pap_count + "</td>";
                cont += "<td>" + d.fleet_participation + "</td>";
                cont += "</tr>"
            }
            tdiv.html(cont);
        });
    }
}