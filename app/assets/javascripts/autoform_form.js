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

    const autoformError = document.getElementById('autoform-error');
    addCloseButtonListener(autoformError);

    const autoformFormError = document.getElementById('autoform-form-error');
    addCloseButtonListener(autoformFormError);

    const emailInputField = document.getElementById('autoform-email');
    emailInputField.addEventListener('click', function (){
        removeErrors(autoformError, autoformFormError)
    });

    const domainInputField = document.getElementById('autoform-domain');
    domainInputField.addEventListener('click', function (){
        removeErrors(autoformError, autoformFormError)
    });
});

function addCloseButtonListener(node) {
    const closeButton = node.querySelector('.alert .close');
    closeButton.addEventListener("click", function (){
        removeErrors(node);
    });
}

function removeErrors(...nodes) {
    $('#autoform-email').parent('.form-group').removeClass('has-error');
    $('#autoform-domain').parent('.form-group').removeClass('has-error');
    nodes.forEach(function(node) {
        $('#' + node.id).hide();
    });
}



