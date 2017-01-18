function init_client_auth() {
    ft.status.set("Checking auth...");

    ft.ident = {};
    ft.ident.token = localStorage.getItem("EclipseFleetTrackerAuthToken");

    if (ft.ident.token) {
        validate_auth_token();
    } else {
        load_login();
    }
}

function validate_auth_token() {
    $.get("/api/login/check", { "token": ft.ident.token }, function(data) {
        if (data.valid) {
            ft.ident = data;
            $.getScript('src/router.js');
        } else {
            load_login();
        }
    });

}

function load_login() {
    $.getScript('/deps/bcrypt.min.js').then(function() {
        return $.get("/login.html", function(data) {
            ft.templates.login = data;
            ft.page.section.body.html(data);
        });
    }).then(function() {
        setup_login();
    });
}

function succeed_login(data) {

}

function fail_login(data) {

}

function submit_credentials() {
    var username_field = $("#username-input");
    var password_field = $("#password-input");

    username_field.prop('disabled', true);
    password_field.prop('disabled', true);

    ft.status.set("Validating credentials...");

    ft.page.section.body.fadeOut(function() {
        ft.page.section.body.html("<h4>Verifying...</h4>");
    }).fadeIn();

    var username = username_field.val();
    var password = password_field.val();

    var stdSalt = "$2a$10$chwuijqBqqzq7mAPQRB3Vu"; //Needs to static for transmission. Unique salts on the server.

    password = dcodeIO.bcrypt.hashSync(password, stdSalt);

    $.get('/login/login', {
        "username": username,
        "password": password
    }, function(data) {
        if (data && data.valid) {
            succeed_login(data);
        } else {
            fail_login(data);
        }
    });
}

function setup_login() {
    ft.status.set("Waiting for user login...");

    ft.page.section.body.fadeIn();
    ft.page.section.footer.fadeIn();

    var submit_button = $("#submit-login-button");
    var username_field = $("#username-input");
    var password_field = $("#password-input");

    function validate_fields(e) {
        if (username_field.val().length < 4 || password_field.val().length < 4) {
            submit_button.prop('disabled', true);
        } else {
            submit_button.prop('disabled', false);
        }
    }

    function capture_enter(e) {
        if (e.which == 13) {
            if (username_field.val().length >= 4 && password_field.val().length >= 4) {
                submit_credentials();
            }
        }
    }

    username_field.on('input', validate_fields);
    password_field.on('input', validate_fields);

    username_field.keypress(capture_enter);
    password_field.keypress(capture_enter);

    submit_button.click(submit_credentials);
}