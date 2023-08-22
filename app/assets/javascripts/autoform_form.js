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

            $.post($(this).attr('action'), formData)
                .done(function() {
                    $('#autoform-error').hide();
                    $('#autoform-form-error').hide();
                    $('#autoform-email').parent('.form-group').removeClass('has-error');
                    $('#autoform-domain').parent('.form-group').removeClass('has-error');
                    $('#autoform-form').hide();
                    $('#autoform-form-sent').show();
                })
                .fail(function() {
                    $('#autoform-form-error').show();
                });

            plausible('Registration', {props: {product: 'Autoform'}});
            return true;
        }
    });

    const wrapper = document.getElementById('flash-message-wrapper')
    wrapper.addEventListener('click', (event) => {
        const isButton = event.target.nodeName === 'SPAN';
        if (!isButton) {return;}

        $('#autoform-email').parent('.form-group').removeClass('has-error');
        $('#autoform-domain').parent('.form-group').removeClass('has-error');

        if(event.target.className === 'error') {
            $('#autoform-error').hide();
        }
        else if(event.target.className === 'form-error') {
            $('#autoform-form-error').hide();
        }
        else if(event.target.className === 'success') {
            $('#autoform-form-sent').hide();
        }
    });

    const emailInputField = document.getElementById('autoform-email');
    emailInputField.addEventListener('click', removeErrors);

    const domainInputField = document.getElementById('autoform-domain');
    domainInputField.addEventListener('click', removeErrors);
});

function removeErrors() {
    $('#autoform-email').parent('.form-group').removeClass('has-error');
    $('#autoform-domain').parent('.form-group').removeClass('has-error');
    $('#autoform-error').hide();
    $('#autoform-form-error').hide();
}



