var nav = {};
var templates = {};
var content_div;
var load_div;
var login_div;
var data = {};

function resetbuttons() {
    nav.button_main.prop("disabled", false);
    nav.button_fleets.prop("disabled", false);
    nav.button_members.prop("disabled", false);
    nav.button_add.prop("disabled", false);
}

function majorError(content, buttons) {
    nav.button_main.prop("disabled", buttons);
    nav.button_fleets.prop("disabled", buttons);
    nav.button_members.prop("disabled", buttons);
    nav.button_add.prop("disabled", buttons);
    content_div.html(content);
}

function loadPage(dest) {
    resetbuttons();

    if (dest == undefined) dest = data.page;
    else data.page = dest;

    if (data.token == undefined) tryLoadAuth();

    var page = data.router[dest];

    if (page == undefined) {
        majorError("<h4>Whoops! The website is confused!</h4><p>The website thinks you want to go to '" + dest + "' which doesn't exist. Please navigate to safety using the buttons above.", false);
    } else {
        if (page.auth) {
            if (data.token != undefined && data.token != null) {
                page.load();
            } else {
                loadlogin();
            }
        } else {
            page.load();
        }
    }

}

function bootstrap() {
    data.router = {};
    data.page = "main";

    //Router page listing.
    data.router.main = {
        auth: false,
        load: loadmain
    };
    data.router.fleets = {
        auth: false,
        load: loadfleets
    };
    data.router.members = {
        auth: false,
        load: loadmembers
    };
    data.router.add = {
        auth: true,
        load: loadadd
    };
    data.router.update = {
        auth: true,
        load: loadupdate
    }


    nav.button_main = $("#button-main");
    nav.button_main.click(function() {
        loadPage("main");
    });

    nav.button_fleets = $("#button-view");
    nav.button_fleets.click(function() {
        loadPage("fleets");
    });

    nav.button_members = $("#button-members");
    nav.button_members.click(function() {
        loadPage("members");
    });

    nav.button_add = $("#button-add");
    nav.button_add.click(function() {
        loadPage("add");
    });

    content_div = $("#content-div");
    load_div = $("#load-div");
    login_div = $("#login-username-div");

    checkSupport();
}

function checkSupport() {
    //Check that the server is alive.
    $.getJSON('/api/ping', function(data) {
        if (data !== "pong") {
            majorError("<h4>Whoops! Server is off!</h4><p>Please contact Columbus or Peacekeeper, or try again later. Sorry!</p>", true);
            return;
        }

        //This is where later support checks can be added.


        loadPage("main");
    });
}