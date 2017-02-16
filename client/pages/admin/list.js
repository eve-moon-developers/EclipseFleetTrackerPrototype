router.pages["admin/list"] = {};

router.pages["admin/list"].show_add_user = function() {
    var template = $("#add-new-user-template").html();
    ft.modal.setup("Add a User", template);
    ft.modal.doShow();
}

router.pages["admin/list"].add_user = function() {

    var username = $("#newUserInputUsername").val();
    var password = $("#newUserInputPassword").val();
    var rank = $("#newUserInputRank").val();

    if (username.length < 4) {
        ft.modal.setup("Error!", "You must supply a username.");
        ft.modal.doShow();
    } else if (password.length < 4) {
        ft.modal.setup("Error!", "You must supply a password.");
        ft.modal.doShow();
    } else if (rank === undefined || rank > 15) {
        ft.modal.setup("Error!", "You must supply a rank.");
        ft.modal.doShow();
    } else {
        ft.modal.doClose();
    }

}

router.pages["admin/list"].update_user = function(id, scope) {
    var me = router.pages["admin/list"];
    ft.modal.setup("Update user: " + me.user_list[id].username, "This hasn't been implemented.");
    ft.modal.doShow();
}

router.pages["admin/list"].delete_user = function(id, scope) {
    var me = router.pages["admin/list"];
    ft.modal.setup("Delete user: " + me.user_list[id].username, "This hasn't been implemented.");
    ft.modal.doShow();
}

router.pages["admin/list"].clear_auth = function(id, scope) {
    var me = router.pages["admin/list"];
    ft.modal.setup("Clear Auth Cache", "This hasn't been implemented.");
    ft.modal.doShow();
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

            me.user_list = {};

            console.log(data);
            var cont = "";
            for (d of data) {

                me.user_list[d.id] = d;

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

                if (d.rank < ft.ident.rank) {
                    cont += "<td><button class='u-full-width' onclick='router.pages[\"admin/list\"].update_user(" + d.id + ", this)'>Update</button></td>";
                    cont += "<td><button class='u-full-width warn-background' onclick='router.pages[\"admin/list\"].delete_user(" + d.id + ", this)'>Delete</button></td>";
                }
                cont += "</tr>"
            }
            tdiv.html(cont);
        });
    }
}