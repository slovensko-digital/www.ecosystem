$(document).ready(function() {
    var consultationsError = $('#consultations-error').get(0);
    if (consultationsError) {
        consultations.addCloseButtonListener(consultationsError);

        var emailInputField = $('#consultations-email').get(0);
        emailInputField.addEventListener('click', function (){
            $('#' + consultationsError.id).hide();
        });
    }

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

var consultations = {
    addCloseButtonListener: function(node) {
        var closeButton = node.querySelector('.alert .close');
        closeButton.addEventListener("click", function (){
            $('#' + node.id).hide();
        });
    }
};