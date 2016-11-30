$(document).ready(function() {
    $('#datahub-form').submit(function() {
        if ($('#datahub-email').val() == '') {
            $('#datahub-form-sent').hide();
            $('#datahub-email').parent('.form-group').addClass('has-error');
            $('#datahub-error').show();

            return false;
        }
        else {
            $('#datahub-error').hide();
            $('#datahub-email').parent('.form-group').removeClass('has-error');
            $('#datahub-form').hide();
            $('#datahub-form-sent').show();

            ga('send', 'event', 'Datahub', 'Registration');
            return true;
        }
    });
});
