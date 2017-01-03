function loadlogin() {
    if (templates.login) {
        content_div.html(templates.login);

        $("#submit-login-button").click(function () { tryLogin(); })

    } else {
        content_div.html("<h4>Loading data...</h4>");
        load_div.load("templates/login.template", function (data) {
            console.log("Loaded login template: \n" + data);
            templates.login = data;
            loadlogin();
        });
    }
}

function tryLogin() {
    var username = $("#usernameInput").val();
    var password = $("#passwordInput").val();

    if (username === "" || password === "") {
        alert("Please supply a username AND password.");
    } else {
        content_div.html("<h4>Verifying login...</h4>");
        $.get("/api/login/login", { "user": username, "pass": password }, function (auth) {
            if (auth === "null") {
                if (!alert('Bad credentials!')) { loadPage(); }
            } else {
                data.auth = auth;
                localStorage.setItem("FleetToolAuthToken", auth);
                loadPage();
            }
        });
    }
}