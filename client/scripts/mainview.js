function loadmain() {
    nav.button_main.prop("disabled", true);
    
    if (templates.main) {
        content_div.html(templates.main);
    } else {
        content_div.html("<h4>Loading data...</h4>");
        load_div.load("templates/main.template", function (data) {
            console.log("Loaded main template: \n" + data);
            templates.main = data;
            loadmain();
        });
    }
}