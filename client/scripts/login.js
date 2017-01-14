function loadlogin() {
    if (templates.login) {
        content_div.html(templates.login);

        $("#submit-login-button").click(function() { tryLogin(); })

    } else {
        content_div.html("<h4>Loading data...</h4>");
        load_div.load("templates/login.template", function(data) {
            console.log("Loaded login template: \n" + data);
            templates.login = data;
            loadlogin();
        });
    }
}

function tryLogin() {
    var username = $("#usernameInput").val();
    var password = $("#passwordInput").val();
    var stdSalt = "$2a$10$chwuijqBqqzq7mAPQRB3Vu"; //Needs to static for transmission. Unique salts on the server.

    password = dcodeIO.bcrypt.hashSync(password, stdSalt);

    if (username === "" || password === "") {
        alert("Please supply a username AND password.");
    } else {
        content_div.html("<h4>Verifying login...</h4>");
        $.get("/api/login/login", { "username": username, "password": password }, function(auth) {
            if (auth === "") {
                if (!alert('Bad credentials!')) {
                    data.page = "main";
                    loadPage();
                }
            } else {
                data.token = auth;
                data.username = username;
                if (localStorage !== undefined) {
                    localStorage.setItem("FleetToolAuthToken", auth);
                }
                updateAuthIcon();
                loadPage();
            }
        });
    }
}

function tryLoadAuth(callback) {
    if (data.token) updateAuthIcon();

    if (data.localStorage == undefined) updateAuthIcon();

    var storedAuth = localStorage.getItem("FleetToolAuthToken");
    if (storedAuth != null) {
        $.get("/api/login/check", { token: storedAuth }, function(result) {
            if (result === "") {
                data.token = null;
                localStorage.removeItem("FleetToolAuthToken");
                updateAuthIcon();
                if (callback) {
                    callback(false);
                }
            } else {
                data.token = storedAuth;
                data.username = result;
                updateAuthIcon();
                if (callback) {
                    callback(true);
                }
            }
        });
    }
}

function updateAuthIcon() {
    if (data.token == null || data.token == undefined) {
        login_div.html("<button id='login-nav-button' onclick=loadlogin()>Login</button>");
    } else if (data.username != undefined) {
        login_div.html("<p>" + data.username + "</p>");
    }
}