$(document).ready(function() {
    var skApiError = $('#sk-api-error').get(0);
    if (skApiError) {
        slovensko_sk_api.addCloseButtonListener(skApiError);

        var emailInputField = $('#sk-api-email').get(0);
        emailInputField.addEventListener('click', function (){
            slovensko_sk_api.removeErrors(skApiError);
        });
    }

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

            plausible('Registration', {props: {product: 'slovensko.sk API'}});
            return true;
        }
    });
});


var slovensko_sk_api = {
    addCloseButtonListener: function(node) {
        var closeButton = node.querySelector('.alert .close');
        closeButton.addEventListener("click", function (){
            slovensko_sk_api.removeErrors(node);
        });
    },

    removeErrors: function(node) {
        $('#sk-api-email').parent('.form-group').removeClass('has-error');
        $('#' + node.id).hide();
    }
};