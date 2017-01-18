router.pages["error"] = {
    handler: function() {
        console.log("Opening error page.");
        ft.page.section.body.show();
        ft.page.section.body.html("<h4>Oh no! An error has occured!</h4>");
    }
};