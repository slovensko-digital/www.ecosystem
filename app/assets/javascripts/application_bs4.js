// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require tether.min
//= require bootstrap.min
//= require newsletter_form
//= require consultations_form
//= require password_confirmation_validator

$(document).on("ready page:change", function () {
  $('[data-toggle="tooltip"]').each(function () {
    var klass = $(this).data('toggle-class');
    $(this).tooltip({
      container: 'body',
      template: '<div class="tooltip" role="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner '+ klass + '"></div></div>'
    });
  });
});

