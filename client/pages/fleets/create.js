router.pages["fleets/create"] = {};

router.pages["fleets/create"].handler = function() {

    console.log("Loading create page...");

    var me = router.pages["fleets/create"];
    if (me.template === undefined) {
        $.get("templates/fleets/add_fleet.html", function(data) {
            me.template = data;
            me.handler();
        });
    } else if (me.categories === undefined) {
        $.get("api/fleet/categories", { "auth": ft.ident }, function(data) {
            me.categories = data;

            //Lets update our template with the categories now. :)
            var node = document.createElement("div");
            node = $(node);
            node.html(me.template);

            var content = "<option value='-1'>Select Category</option>";
            var rows = "";
            me.categories.forEach(function(c) {
                console.log(c);
                content += "<option value='" + c.type_id + "'>" + c.name + "</option>";
                rows += "<tr><td>" + c.name + "</td><td>" + c.description + "</td></tr>";
            });

            node.find("#fleetImportanceInput").html(content);
            node.find("#fleet-type-table-body").html(rows);
            me.template = node.html();

            me.handler();
        });
    } else {
        ft.page.section.body.html(me.template);
        ft.page.section.body.fadeIn();

        router.clear_buttons();
        ft.page.nav.create.prop('disabled', true);

        ft.page.section.body.find("#submit-fleet-add-button").click(function() {
            var package = {};
            package.fc = $("#fcNameInput").val();
            package.title = $("#fleetTitleInput").val();
            package.importance = $("#fleetImportanceInput").val();
            package.description = escape($("#fleetDescriptionInput").val());
            package.composition = $("#fleetDoctrineInput").val();
            package.auth = ft.ident;
            $.post("/api/fleet/create", package, function(data) {
                console.log(data);
                if (data.valid) {
                    router.load("#fleets/update$" + data.id);
                }
            });
        });
    }
}