router.pages["admin/list"] = {};

router.pages["admin/list"].delete_user = function(id, scope) {

}

router.pages["admin/list"].change_password = function(id, scope) {

}

router.pages["admin/list"].change_rank = function(id, scope) {

}

router.pages["admin/list"].add_user = function(id) {

}

router.pages["admin/list"].handler = function() {

    var me = router.pages["admin/list"];
    if (me.template === undefined) {
        console.log("Loading fleets page...");
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
                    var seconds = (Date.now() - created) / 1000;

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

                /*
                if (d.modified == null) {
                    cont += "<td>&#x221e;</td>"
                } else {
                    var created = new Date(d.modified);
                    //console.log(created);
                    var seconds = (Date.now() - created) / 1000;

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
                    var seconds = (Date.now() - created) / 1000;

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
                */
                if (d.rank < ft.ident.rank) {
                    cont += "<td><button>Rank</button></td>";
                    cont += "<td><button>Password</button></td>";
                    cont += "<td><button>Delete</button></td>";
                }
                cont += "</tr>"
            }
            tdiv.html(cont);
        });
    }
}