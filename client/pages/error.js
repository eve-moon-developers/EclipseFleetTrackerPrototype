router.pages["error"] = {
    handler: function() {

        router.clear_buttons();
        console.log("Opening error page.");
        ft.page.section.body.show();
        var message = "<h4>Oh no! An error has occured!</h4>";
        if (router.error_message) {
            message += "<p>" + router.error_message + "</p>";
        }
        ft.page.section.body.html(message);

    }
};