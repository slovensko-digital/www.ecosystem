$(document).ready(function() {
    var datahubError = $('#datahub-error').get(0);
    if (datahubError) {
        datahub.addCloseButtonListener(datahubError);

        var emailInputField = $('#datahub-email').get(0);
        emailInputField.addEventListener('click', function (){
            datahub.removeErrors(datahubError);
        });
    }

    $('#datahub-form').submit(function() {
        if ($('#datahub-email').val() == '') {
            $('#datahub-form-sent').hide();
            $('#datahub-email').parent('.form-group').addClass('has-error');
            $('#datahub-error').show();

            return false;
        }
        else {
            $('#datahub-error').hide();
            $('#datahub-email').parent('.form-group').removeClass('has-error');
            $('#datahub-form').hide();
            $('#datahub-form-sent').show();

            plausible('Registration', {props: {product: 'Datahub'}});
            return true;
        }
    });
});

var datahub = {
    addCloseButtonListener: function(node) {
        var closeButton = node.querySelector('.alert .close');
        closeButton.addEventListener("click", function (){
            datahub.removeErrors(node);
        });
    },
    
    removeErrors: function(node) {
        $('#datahub-email').parent('.form-group').removeClass('has-error');
        $('#' + node.id).hide();
    }
};