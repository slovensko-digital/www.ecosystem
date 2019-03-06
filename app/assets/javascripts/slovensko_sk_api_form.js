$(document).ready(function() {
    $('#sk-api-form').submit(function() {
        if ($('#sk-api-email').val() == '') {
            $('#sk-api-form-sent').hide();
            $('#sk-api-email').parent('.form-group').addClass('has-error');
            $('#sk-api-error').show();

            return false;
        }
        else {
            $('#sk-api-error').hide();
            $('#sk-api-email').parent('.form-group').removeClass('has-error');
            $('#sk-api-form').hide();
            $('#sk-api-form-sent').show();

            ga('send', 'event', 'slovensko.sk API', 'Registration');
            return true;
        }
    });
});
