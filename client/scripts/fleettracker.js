var template = {};
var data = {};

function resetbuttons() {
    template.button_main.prop("disabled", false);
    template.button_fleets.prop("disabled", false);
    template.button_members.prop("disabled", false);
    template.button_add.prop("disabled", false);
}

function unsupportedBrowser(reason) {
    template.button_main.prop("disabled", true);
    template.button_fleets.prop("disabled", true);
    template.button_members.prop("disabled", true);
    template.button_add.prop("disabled", true);
    template.content.html("<h4>Your browser is unsupported.</h4><p>" + reason + "</p>");
}

function checkSupport() {
    if (typeof (Storage) === "undefined") {
        unsupportedBrowser("This browser doesn't support local storage. Please use a standard up to date browser.");
        return;
    }

    loadPage();
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
    data.auth = localStorage.getItem("FleetToolAuthToken");
    data.expiry = localStorage.getItem("FleetToolAuthExpiry");

    //CHECK AUTH.
    if (data.auth === undefined) {
        loadlogin();
        return;
    } else if (data.expiry < new Date().getTime()) {
        loadlogin();
        return;
    }

    //AUTH PAGES GO HERE.
    if (data.page == "add") {
        loadadd();
    } else {
        template.content.html("<h4>Page not found! Please select a button above.</h4>");
    }
}

function bootstrap() {
    template.content = $("#content-div");

    template.button_main = $("#button-main");
    template.button_main.click(function () { data.page = "main"; loadPage(); });

    template.button_fleets = $("#button-view");
    template.button_fleets.click(function () { data.page = "fleets"; loadPage(); });

    template.button_members = $("#button-members");
    template.button_members.click(function () { data.page = "members"; loadPage(); });

    template.button_add = $("#button-add");
    template.button_add.click(function () { data.page = "add"; loadPage(); });

    data.page = "main";

    checkSupport();
    loadPage();
}