$(document).on("ready page:change paste", function() {
    $('[data-password-confirm]').each(function() {
        var password_elm = $(this).get(0);
        var password_confirmation_elm = document.getElementById($(this).data('password-confirm'));

        var validator = function() {
            if (password_elm.value !== password_confirmation_elm.value) {
                password_confirmation_elm.setCustomValidity("Heslá musia byť rovnaké.");
            } else {
                password_confirmation_elm.setCustomValidity('');
            }
        };

        password_elm.input = password_confirmation_elm.onkeyup = validator;
    });
});
