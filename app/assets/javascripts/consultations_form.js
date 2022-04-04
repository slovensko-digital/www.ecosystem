$(document).ready(function() {
    $('#consultations-form').submit(function() {
        if ($('#consultations-email').val() == '') {
            $('#consultations-sent').hide();
            $('#consultations-email').parent('.form-group').addClass('has-error');
            $('#consultations-error').show();

            return false;
        }
        else {
            $('#consultations-error').hide();
            $('#consultations-email').parent('.form-group').removeClass('has-error');
            $('#consultations-form').hide();
            $('#consultations-sent').show();

            plausible('Registration', {props: {product: 'konzultacie'}});
            return true;
        }
    });
});
