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
            var formData = $(this).serialize();

            $.ajax($(this).attr('action'), {
                data: formData,
                dataType: "jsonp",
                complete: function(response) {
                    if (response.status === 200) {
                        $('#autoform-error').hide();
                        $('#autoform-form-error').hide();
                        $('#autoform-email').parent('.form-group').removeClass('has-error');
                        $('#autoform-domain').parent('.form-group').removeClass('has-error');
                        $('#autoform-form').hide();
                        $('#autoform-form-sent').show();

                    }
                    else {
                        $('#autoform-form-error').show();
                    }
                },
                error: function() {
                    $('#autoform-form-error').show();
                },
                timeout: 5000
            });

            plausible('Registration', {props: {product: 'Autoform'}});
            return true;
        }
    });

    var autoformError = $('#autoform-error').get(0);
    addCloseButtonListener(autoformError);

    var autoformFormError = $('#autoform-form-error').get(0);
    addCloseButtonListener(autoformFormError);

    var emailInputField = $('#autoform-email').get(0);
    emailInputField.addEventListener('click', function (){
        removeErrors(autoformError, autoformFormError)
    });

    var domainInputField = $('#autoform-domain').get(0);
    domainInputField.addEventListener('click', function (){
        removeErrors(autoformError, autoformFormError)
    });
});

function addCloseButtonListener(node) {
    var closeButton = node.querySelector('.alert .close');
    closeButton.addEventListener("click", function (){
        removeErrors(node);
    });
}

function removeErrors() {
    $('#autoform-email').parent('.form-group').removeClass('has-error');
    $('#autoform-domain').parent('.form-group').removeClass('has-error');

    for(var node = 0; node < arguments.length; node++) {
        $('#' + arguments[node].id).hide();
    }
}



