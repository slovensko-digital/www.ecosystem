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
//= require bootstrap-sprockets
//= require prism.js
//= require anchor.min.js
//= require datahub_form
//= require autoform_form
//= require slovensko_sk_api_form
//= require password_confirmation_validator

$(document).on("ready page:change", function() {
    $('[data-toggle="tooltip"]').tooltip({container: 'body'});
});

$(function () {
    anchors.options.placement = 'left';
    anchors.add('.anchors h1, .anchors h2, .anchors h3, .anchors h4, .anchorable');
});
