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


    // Modal
    ft.modal = {};
    ft.modal.title = $("#modal-title");
    ft.modal.content = $("#modal-content");
    ft.modal.close = $("#modal-close-button");
    ft.modal.outline = $("#modal-outline");
    ft.modal.container = $("#modal-container");

    ft.modal.doSafeClose = function() {
        if (ft.modal.before_close && _.isFunction(ft.modal.before_close)) {
            Promise.resolve(ft.modal.before_close()).then(t => ft.modal.container.hide(), t => ft.modal.container.hide);
        } else {
            ft.modal.container.hide();
        }
    }

    ft.modal.doClose = function() {
        ft.modal.container.hide();
    }

    ft.modal.setup = function(title, content) {
        ft.modal.title.html(title);
        ft.modal.content.html(content);
    }

    ft.modal.doShow = function(allowClickOff, optional_callback) {
        if (allowClickOff == false) {
            ft.modal.outline.off("click", ft.modal.doSafeClose);
        } else {
            ft.modal.outline.on("click", ft.modal.doSafeClose);
        }
        ft.modal.before_close = optional_callback;
        ft.modal.container.show();
    }

    ft.modal.close.click(ft.modal.doSafeClose);


    //Load auth.
    $.getScript("src/auth.js").then(function() {
        init_client_auth();
    });
}

function check_support() {
    //Check for browser support here.
}