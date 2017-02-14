var router = {};

router.pages = {};

router.pages["fleets/list"] = false;
router.pages["fleets/update"] = false;
router.pages["fleets/view"] = false;
router.pages["fleets/create"] = false;
router.pages["admin/list"] = false;
router.pages["members"] = false;
router.pages["dashboard"] = false;
router.pages["error"] = false;

router.reload = function() {
    if (location.hash == "") {
        location.hash = "#dashboard";
    }

    router.hash = location.hash.replace("#", "").split("$");

    if (router.pages[router.hash[0]] == undefined) {
        location.hash = "#error";
        return router.reload();
    } else {
        if (router.pages[router.hash[0]] == false) {
            $.getScript("pages/" + router.hash[0] + ".js").then(function() { router.reload(); });
            console.log("Loading new page: " + router.hash[0]);
        } else {
            router.pages[router.hash[0]].handler();
        }
    }

};

router.load = function(val) {
    location.hash = val;
    router.reload();
}

function init_router() {
    ft.page.section.nav.fadeIn();
    ft.page.section.footer.fadeIn();

    router.reload();

    ft.status.set(ft.ident.ident);

    ft.page.nav.fleets.click(function() { router.load("#fleets/list"); });
    ft.page.nav.members.click(function() { router.load("#members"); });
    ft.page.nav.create.click(function() { router.load("#fleets/create"); });
    ft.page.nav.dashboard.click(function() { router.load("#dashboard"); });

}

router.clear_buttons = function() {
    ft.page.nav.fleets.prop('disabled', false);
    ft.page.nav.members.prop('disabled', false);
    ft.page.nav.create.prop('disabled', false);
    ft.page.nav.dashboard.prop('disabled', false);
}

init_router();