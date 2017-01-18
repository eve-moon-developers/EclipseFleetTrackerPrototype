function bootstrap() {
    //Create the global data holder.
    ft = {};

    //Create the status object.
    ft.status = {};
    ft.status.obj = $("#main-status-badge");
    ft.status.set = function(text) {
        ft.status.obj.html(text);
    }
    ft.status.set("Loading site...");

    //Load the page structure.
    ft.page = {};

    ft.page.section = {};
    ft.page.section.header = $("#main-header-div");
    ft.page.section.nav = $("#main-menu-div");
    ft.page.section.body = $("#main-body-div");
    ft.page.section.footer = $("#main-footer-div");

    ft.page.nav = {};
    ft.page.nav.fleets = $("#button-nav-fleets");
    ft.page.nav.members = $("#button-nav-members");
    ft.page.nav.create = $("#button-nav-create");
    ft.page.nav.dashboard = $("#button-nav-user");

    ft.page.section.header.fadeIn();

    //Some empty objects
    ft.templates = {};

    //Create the load section.
    ft.page.load = document.createElement("div");

    check_support();

    //Load auth.
    $.getScript("src/auth.js").then(function() {
        init_client_auth();
    });
}

function check_support() {
    //Check for browser support here.
}