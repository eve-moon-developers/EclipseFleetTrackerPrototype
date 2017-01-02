
var template = {};

function resetbuttons() {
    template.button_main.prop("disabled", false);
    template.button_fleets.prop("disabled", false);
    template.button_members.prop("disabled", false);
    template.button_add.prop("disabled", false);
}

function bootstrap() {
    template.content = $("#content-div");

    template.button_main = $("#button-main");
    template.button_main.click(function() { loadmain(); });

    template.button_fleets = $("#button-view");
    template.button_fleets.click(function() { loadfleets(); });

    template.button_members = $("#button-members");
    template.button_members.click(function() { loadmembers(); });

    template.button_add = $("#button-add");
    template.button_add.click(function() { loadadd(); });

    loadmain();
}