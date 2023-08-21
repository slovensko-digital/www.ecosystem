$(document).ready(function() {
    $('#autoform-form').submit(function(event) {
        event.preventDefault();
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
            const formData = $(this).serialize();
            $.post($(this).attr('action'), formData, function(response) {

            }).complete(function(jqxhr) {
                if (jqxhr.status === 200) {
                    $('#autoform-error').hide();
                    $('#autoform-form-error').hide();
                    $('#autoform-email').parent('.form-group').removeClass('has-error');
                    $('#autoform-domain').parent('.form-group').removeClass('has-error');
                    $('#autoform-form').hide();
                    $('#autoform-form-sent').show();

                } else {
                    $('#autoform-form-error').show();
                }
            });

            plausible('Registration', {props: {product: 'Autoform'}});
            return true;
        }
    });
});