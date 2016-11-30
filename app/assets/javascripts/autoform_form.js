$(document).ready(function() {
    $('#autoform-form').submit(function() {
        if ($('#autoform-email').val() == '' || $('#autoform-domain').val() == '') {
            $('#autoform-form-sent').hide();
            if ($('#autoform-email').val() == '') {
                $('#autoform-email').parent('.form-group').addClass('has-error');
            }
            else {
                $('#autoform-email').parent('.form-group').removeClass('has-error');
            }
            if ($('#autoform-domain').val() == '') {
                $('#autoform-domain').parent('.form-group').addClass('has-error');
            }
            else {
                $('#autoform-domain').parent('.form-group').removeClass('has-error');
            }
            $('#autoform-error').show();

            return false;
        }
        else {
            $('#autoform-error').hide();
            $('#autoform-email').parent('.form-group').removeClass('has-error');
            $('#autoform-domain').parent('.form-group').removeClass('has-error');
            $('#autoform-form').hide();
            $('#autoform-form-sent').show();

            ga('send', 'event', 'Autoform', 'Registration');
            return true;
        }
    });
});
