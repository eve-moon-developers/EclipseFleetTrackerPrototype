router.pages["dashboard"] = {};

router.pages["dashboard"].handler = function() {

    console.log("Loading dashboard page...");

    var me = router.pages["dashboard"];
    if (me.template === undefined) {
        $.get("templates/dashboard.html", function(data) {
            me.template = data;
            me.handler();
        });
    } else {
        if (ft.ident.rank >= 10) {
            var admin_button = "<button class='u-full-width warn-background warn-strong-text' onclick=\"router.load('admin/list')\" >Admin Panel</button>";
            me.template = admin_button + me.template;
        }
        ft.page.section.body.html(me.template);
        ft.page.section.body.fadeIn();

        router.clear_buttons();
        ft.page.nav.dashboard.prop('disabled', true);
    }
}