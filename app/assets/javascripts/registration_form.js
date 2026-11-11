// The registration without a Slovak IČO (registrations/_form): the client
// writes the address instead of the IČO and Autoform suggests no companies.
$(function () {
    var form = $('#cap-registration-form');
    var withoutIco = form.find('#cap_without_ico');
    var name = form.find('#cap_company_name');
    var nameLabel = form.find('label[for="cap_company_name"]');

    withoutIco.on('change', function () {
        var checked = withoutIco.prop('checked');

        form.find('#cap-registration-ico').prop('hidden', checked).find('input').prop('disabled', checked);
        form.find('#cap-registration-address').prop('hidden', !checked).find('input').prop('disabled', !checked);
        nameLabel.text(nameLabel.data(checked ? 'without-ico' : 'company'));
    });

    // Autoform sets up its suggestions later, the event of a search is there already.
    name.on('autocompletesearch', function () {
        return !withoutIco.prop('checked');
    });
});
