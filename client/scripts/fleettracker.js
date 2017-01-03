var nav = {};
var templates = {};
var content_div;
var load_div;
var data = {};

function resetbuttons() {
    nav.button_main.prop("disabled", false);
    nav.button_fleets.prop("disabled", false);
    nav.button_members.prop("disabled", false);
    nav.button_add.prop("disabled", false);
}

function unsupportedBrowser(content) {
    nav.button_main.prop("disabled", true);
    nav.button_fleets.prop("disabled", true);
    nav.button_members.prop("disabled", true);
    nav.button_add.prop("disabled", true);
    content_div.html(content);
}

function checkSupport() {
    //Check that the server is alive.
    $.getJSON('/api/ping', function (data) {
        if (data !== "pong") {
            unsupportedBrowser("<h4>Whoops! Server is off!</h4><p>Please contact Columbus or Peacekeeper, or try again later. Sorry!</p>");
            return;
        }

        //Check that the browser supports Local Storage
        if (typeof (Storage) === "undefined") {
            unsupportedBrowser("<h4>Unsupported Browser</h4><p>This browser doesn't support local storage. Please use a standard up to date browser.</p>");
            return;
        }

        loadPage();
    });
}

function loadPage() {
    resetbuttons();

    //NON AUTH PAGES GO HERE.
    if (data.page === "main") {
        loadmain();
        return;
    } else if (data.page === "fleets") {
        loadfleets();
        return;
    } else if (data.page === "members") {
        loadmembers();
        return;
    }

    //FETCH AUTH.
    console.log("Auth: " + data.auth);
    if (!data.auth) {
        var storedAuth = localStorage.getItem("FleetToolAuthToken");
        if (storedAuth !== null) {
            content_div.html("<h4>Verifying login...</h4>");
            $.get("/api/login/check", { token: storedAuth }, function (result) {
                if (result === false) {
                    data.auth = undefined;
                    localStorage.removeItem("FleetToolAuthToken");
                    loadlogin();
                } else {
                    data.auth = storedAuth;
                    loadPage();
                }
            });
        } else {
            loadlogin();
        }
        return;
    }

    //AUTH PAGES GO HERE.
    if (data.page == "add") {
        loadadd();
    } else {
        content_div.html("<h4>Page not found! Please select a button above.</h4>");
    }
}

function bootstrap() {

    nav.button_main = $("#button-main");
    nav.button_main.click(function () { data.page = "main"; loadPage(); });

    nav.button_fleets = $("#button-view");
    nav.button_fleets.click(function () { data.page = "fleets"; loadPage(); });

    nav.button_members = $("#button-members");
    nav.button_members.click(function () { data.page = "members"; loadPage(); });

    nav.button_add = $("#button-add");
    nav.button_add.click(function () { data.page = "add"; loadPage(); });

    data.page = "main";

    content_div = $("#content-div");
    load_div = $("#load-div");

    checkSupport();
    loadPage();
}