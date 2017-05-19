// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require_tree .

$(document).ready(function(){
    $('[data-toggle="tooltip"]').tooltip();
});

var KEY_PREFIX = "ood_editor_store_";

// Set localStorage. Adds a key prefix to reduce overlap likelihood.
function setUserPreference(key, value) {
    var ood_key = KEY_PREFIX + key;
    localStorage.setItem(ood_key, value);
    return null;
}

// Get localStorage. Adds a key prefix added by setter.
function getUserPreference(key) {
    var ood_key = KEY_PREFIX + key;
    return localStorage.getItem(ood_key);
}
