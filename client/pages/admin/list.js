router.pages["admin/list"] = {};

router.pages["admin/list"].handler = function() {

    console.log("Loading fleets page...");

    var me = router.pages["admin/list"];
    if (me.template === undefined) {
        $.get("templates/admin/list_users.html", function(data) {
            me.template = data;
            me.handler();
        });
    } else {
        ft.page.section.body.html(me.template);
        ft.page.section.body.fadeIn();

        router.clear_buttons();

        var tdiv = $("#view-logins-body");

        $.get("/api/admin/list", { auth: ft.ident }).then(data => {
            console.log(data);
            var cont = "";
            for (d of data) {
                cont += "<tr>";
                cont += "<td>" + d.id + "</td>";
                cont += "<td>" + d.username + "</td>";
                cont += "<td>" + d.rank + "</td>";

                if (d.created == null) {
                    cont += "<td>&#x221e;</td>"
                } else {
                    var created = new Date(d.created);
                    //console.log(created);
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

                if (d.modified == null) {
                    cont += "<td>&#x221e;</td>"
                } else {
                    var created = new Date(d.modified);
                    //console.log(created);
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

                if (d.last_login == null) {
                    cont += "<td>&#x221e;</td>"
                } else {
                    var created = new Date(d.last_login);
                    //console.log(created);
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
                cont += "<td><button onclick=router.load('#admin/update$" + d.id +
                    "')>Update</button></td>";
                cont += "</tr>"
            }
            tdiv.html(cont);
        });
    }
}