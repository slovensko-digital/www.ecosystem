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

            plausible('Registration', {props: {product: 'Autoform'}});
            return true;
        }
    });

    var autoformError = $('#autoform-error').get(0);
    addCloseButtonListener(autoformError);

    var emailInputField = $('#autoform-email').get(0);
    emailInputField.addEventListener('click', function (){
        removeErrors(autoformError)
    });

    var domainInputField = $('#autoform-domain').get(0);
    domainInputField.addEventListener('click', function (){
        removeErrors(autoformError)
    });
});

function addCloseButtonListener(node) {
    var closeButton = node.querySelector('.alert .close');
    closeButton.addEventListener("click", function (){
        removeErrors(node);
    });
}

function removeErrors(node) {
    $('#autoform-email').parent('.form-group').removeClass('has-error');
    $('#autoform-domain').parent('.form-group').removeClass('has-error');
    $('#' + node.id).hide();
}



