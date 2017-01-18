router.pages["update"] = {};

router.pages["update"].handler = function() {

    console.log("Loading update page...");

    var me = router.pages["update"];
    if (me.template === undefined) {
        $.get("templates/update_fleet.html", function(data) {
            me.template = data;
            me.handler();
        });
    } else {
        ft.page.section.body.html(me.template);
        ft.page.section.body.fadeIn();

        router.clear_buttons();
        ft.page.nav.update.prop('disabled', true);
    }
}