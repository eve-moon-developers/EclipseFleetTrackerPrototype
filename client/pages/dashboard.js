router.pages["dashboard"] = {};

router.pages["dashboard"].change_password = function() {
    var content = $("#change-password-template").html();

    ft.modal.setup("Reset Your Password", content);

    var newPassword = ft.modal.content.find("#change-password-input");
    var newPasswordConfirm = ft.modal.content.find("#change-password-input-confirm");
    var newPasswordSubmit = ft.modal.content.find("#change-password-submit-button");
    var newPasswordMessage = ft.modal.content.find("#change-password-message");

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

    ft.modal.doShow();
}

router.pages["dashboard"].submit_change_password = function() {
    ft.modal.setup("Password changed!", "This isn't implemented yet.");
    ft.modal.doShow();
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