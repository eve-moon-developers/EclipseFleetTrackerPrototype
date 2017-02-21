router.pages["admin/list"] = {};

router.pages["admin/list"].show_add_user = function() {
    var template = $("#add-new-user-template").html();
    ft.modal.setup("Add a User", template);

    var username = ft.modal.content.find("#newUserInputUsername");
    var rank = ft.modal.content.find("#newUserInputRank");
    var submit = ft.modal.content.find("#submitNewUserButton");

    var checkConditions = function() {
        if (username.val().trim().length < 5) {
            submit.prop("disabled", true);
        } else if (rank.val() === undefined || rank.val() == "" || rank.val() < 0 || rank.val() > 10) {
            submit.prop("disabled", true);
        } else {
            submit.prop("disabled", false);
        }
    }

    username.on("input", checkConditions);
    rank.on("input", checkConditions);

    if (typeof dcodeIO == 'undefined') {
        $.getScript('/deps/bcrypt.min.js').then(() => ft.modal.doShow());
    } else {
        ft.modal.doShow();
    }
}


ft.genRandomPassword = function() {
    var retVal = "";
    var length = 8,
        charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
        random_password = "";
    for (var i = 0, n = charset.length; i < length; ++i) {
        retVal += charset.charAt(Math.floor(Math.random() * n));
    }
    return retVal;
}

router.pages["admin/list"].add_user = function() {
    var username = ft.modal.content.find("#newUserInputUsername").val();
    var rank = ft.modal.content.find("#newUserInputRank").val();

    if (username.trim().length < 5) {
        ft.modal.setup("Error!", "You must supply a username at least 5 characters long.");
        ft.modal.doShow();
    } else if (rank === undefined || rank < 0 || rank > 10) {
        ft.modal.setup("Error!", "You must supply a rank between 0 and 10.");
        ft.modal.doShow();
    } else {
        var raw_password = ft.genRandomPassword();

        var stdSalt = "$2a$10$chwuijqBqqzq7mAPQRB3Vu"; //Needs to static for transmission. Unique salts on the server.
        password = dcodeIO.bcrypt.hashSync(raw_password, stdSalt);

        $.post("api/admin/add", { auth: ft.ident, "username": username, "rank": rank, "password": password }).done(function() {
            var message = "User has been added with password: " + raw_password + ". For convenience you may copy paste this message to them:<br><br>";
            message += "Eclipse Fleet Tool: https://app3.thebestcorp.org " + username + " " + raw_password + " - Please change your password.";
            message += "<br><br>Click anywhere grey, or the red X to continue.";
            ft.modal.setup("User added!", message);
            ft.modal.doShow();
        }).fail(function(xhr, status, error) {
            ft.modal.setup("User was not added!", "The server returned:<br><br>" + xhr.responseText + "<br><br>Click anywhere grey, or the red X to continue.");
            ft.modal.doShow(true, () => location.reload());
        });
    }

}

router.pages["admin/list"].update_user = function(id, scope) {
    var me = router.pages["admin/list"];

    var content = $("#update-user-template").html();

    ft.modal.setup("Update user: " + me.user_list[id].username, content);

    var rank = ft.modal.content.find("#update-user-rank");
    var rankButton = ft.modal.content.find("#update-user-rank-button");
    var passwordButton = ft.modal.content.find("#reset-user-password-button");
    var unlockPasswordButton = ft.modal.content.find("#unlock-reset-user-password-button");

    rank.on("input", function() {
        if (rank.val() === undefined || rank.val() === "" || rank.val() < 0 || rank.val() > 10) {
            rankButton.prop("disabled", true);
            if (rank.val() === "") {
                passwordButton.prop("disabled", true);
                unlockPasswordButton.prop("disabled", false);
            } else {
                passwordButton.prop("disabled", true);
                unlockPasswordButton.prop("disabled", true);
            }
        } else {
            rankButton.prop("disabled", false);
            passwordButton.prop("disabled", true);
            unlockPasswordButton.prop("disabled", true);
        }
    });

    rankButton.click(() => {
        var rank_val = rank.val();
        var user_id = id;

        $.post("api/admin/update/rank", { auth: ft.ident, "user_id": user_id, "rank": rank_val }).done(function() {
            ft.modal.setup("User rank updated!", "User " + me.user_list[id].username + " has had their rank changed to " + rank_val +
                "<br><br>Close the modal to reload the site.<br>Click anywhere grey, or the red X to continue.");
            ft.modal.doShow(true, () => location.reload());
        }).fail(function(xhr, status, error) {
            ft.modal.setup("Password was not changed!", "The server returned:<br><br>" + xhr.responseText + "<br><br>Click anywhere grey, or the red X to continue.");
            ft.modal.doShow(true, () => location.reload());
        });
    });

    unlockPasswordButton.click(() => {
        passwordButton.prop("disabled", false);
        unlockPasswordButton.prop("disabled", true);
        rank.prop("disabled", true);
    });

    passwordButton.click(() => {
        var raw_password = ft.genRandomPassword();

        var stdSalt = "$2a$10$chwuijqBqqzq7mAPQRB3Vu"; //Needs to static for transmission. Unique salts on the server.
        password = dcodeIO.bcrypt.hashSync(raw_password, stdSalt);

        $.post("api/admin/update/password", { auth: ft.ident, "user_id": id, "password": password }).done(function() {
            var message = "User's password has been reset: " + raw_password + ". For convenience you may copy paste this message to them:<br><br>";
            message += "Eclipse Fleet Tool: https://app3.thebestcorp.org " + me.user_list[id].username + " " + raw_password + " - Please change your password.";
            message += "<br><br>Click anywhere grey, or the red X to continue.";
            ft.modal.setup("Password reset!", message);
            ft.modal.doShow();
        }).fail(function(xhr, status, error) {
            ft.modal.setup("User's password was not reset!", "The server returned:<br><br>" + xhr.responseText + "<br><br>Click anywhere grey, or the red X to continue.");
            ft.modal.doShow(true, () => location.reload());
        });
    });

    if (typeof dcodeIO == 'undefined') {
        $.getScript('/deps/bcrypt.min.js').then(() => ft.modal.doShow());
    } else {
        ft.modal.doShow();
    }

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

                /*
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
                */

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