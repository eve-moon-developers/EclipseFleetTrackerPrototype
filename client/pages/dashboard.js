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
        var template_html = "";
        if (ft.ident.rank >= 10) {
            template_html += "<button class='u-full-width warn-background warn-strong-text' onclick=\"router.load('admin/list')\" >Admin Panel</button>";
        }
        template_html += me.template;
        ft.page.section.body.html(template_html);
        ft.page.section.body.fadeIn();

        router.clear_buttons();
        ft.page.nav.dashboard.prop('disabled', true);
    }
}