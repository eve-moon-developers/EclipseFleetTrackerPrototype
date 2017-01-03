function loadfleets() {
    nav.button_fleets.prop("disabled", true);
    content_div.html("<h4>Fleets Page Selected</h4><p>This page will later contain a list of all fleets with paging sorted by time and catagory. FCs will be able to update fleet attendance so we can track how a fleet changes over time. Update a fleet will require an auth check.");
}