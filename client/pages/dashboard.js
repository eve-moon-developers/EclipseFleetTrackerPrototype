router.pages["dashboard"] = {};

router.pages["dashboard"].change_password = function() {
    var me = router.pages["dashboard"];

    if (me.password_template === undefined) {
        me.password_template = $("#change-password-template").html();
    }

    ft.modal.setup("Reset Your Password", me.password_template);

    me.change_password_values = {}; //We want to clear this every time as we generate new html.

    var newPassword = ft.modal.content.find("#change-password-input");
    var newPasswordConfirm = ft.modal.content.find("#change-password-input-confirm");
    var newPasswordSubmit = ft.modal.content.find("#change-password-submit-button");
    var newPasswordMessage = ft.modal.content.find("#change-password-message");

    me.change_password_values.password1input = newPassword;
    me.change_password_values.password2input = newPasswordConfirm;

    newPasswordMessage.text("Password must be at least 6 characters.");
    newPasswordSubmit.prop("disabled", true);

    var passwordCheckFunction = function() {
        if (newPassword.val().length < 6) {
            newPasswordMessage.text("Password must be at least 6 characters.");
            newPasswordSubmit.prop("disabled", true);
        } else if (newPassword.val() !== newPasswordConfirm.val()) {
            newPasswordMessage.text("Passwords must match.");
            newPasswordSubmit.prop("disabled", true);
        } else {
            newPasswordMessage.text("");
            newPasswordSubmit.prop("disabled", false);
        }
    };

    newPassword.on('input', passwordCheckFunction);
    newPasswordConfirm.on('input', passwordCheckFunction);

    if (typeof dcodeIO == 'undefined') {
        $.getScript('/deps/bcrypt.min.js').then(() => ft.modal.doShow());
    } else {
        ft.modal.doShow();
    }
}

router.pages["dashboard"].submit_change_password = function() {
    var me = router.pages["dashboard"].change_password_values;

    if (me.password1input.val().length < 6) {
        ft.modal.setup("Could not change password!", "Supplied password is not at least 6 characters long.");
    } else if (me.password1input.val() !== me.password2input.val()) {
        ft.modal.setup("Could not change password!", "Supplied passwords do not match.");
    } else {
        var stdSalt = "$2a$10$chwuijqBqqzq7mAPQRB3Vu"; //Needs to static for transmission. Unique salts on the server.
        password = dcodeIO.bcrypt.hashSync(me.password1input.val(), stdSalt);
        $.post("api/login/change", { auth: ft.ident, new_password: password }).done(function() {
            ft.modal.setup("Password changed!", "Your password has been changed. Close the modal to reload the site.<br>Click anywhere grey, or the red X to continue.");
            ft.modal.doShow(true, () => location.reload());
        }).fail(function(xhr, status, error) {
            ft.modal.setup("Password was not changed!", "The server returned:<br><br>" + xhr.responseText + "<br><br>Click anywhere grey, or the red X to continue.");
            ft.modal.doShow(true, () => location.reload());
        });
    }
}

router.pages["dashboard"].log_out = function() {
    var content = $("#log-out-template").html();
    ft.modal.setup("Log out", content);
    ft.modal.doShow();
}

router.pages["dashboard"].handler = function() {
    console.log("Loading dashboard page...");

    var me = router.pages["dashboard"];

    if (me.template === undefined) {
        $.get("templates/dashboard.html", function(data) {
            me.template = data;
            me.handler();
        });
    } else {
        var template_html = "";
        if (ft.ident.rank >= 10) {
            template_html += "<button class='u-full-width warn-background warn-strong-text' onclick='router.load(\"admin/list\")' >Admin Panel</button>";
        }
        template_html += me.template;

        ft.page.section.body.html(template_html);
        ft.page.section.body.fadeIn();

        router.clear_buttons();
        ft.page.nav.dashboard.prop('disabled', true);
    }
}