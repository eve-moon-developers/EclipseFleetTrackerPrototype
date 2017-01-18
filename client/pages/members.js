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
    }
}