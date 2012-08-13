# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ = jQuery # local var for use with jQuery - works even if
# noConflict is set elsewhere
$ ->  # shortcut for $(document).ready..
  
  # set OAuth login form based on environment
  $('a#environment-gus').click ->
    $('form#login').attr('action', '/auth/gus')
    $('span#login-button-text').html('Login with GUS')
  $('a#environment-production').click ->
    $('form#login').attr('action', '/auth/salesforce')
    $('span#login-button-text').html('Login with Salesforce')
  $('a#environment-blitz01').click ->
    $('form#login').attr('action', '/auth/blitz01')
    $('span#login-button-text').html('Login with Blitz01')
    
  $('a#environment-dropdown').tooltip({placement: 'bottom'})
  
# redirect users who have antique browsers
browser   = navigator.appName
ver     = navigator.appVersion
thestart  = parseFloat(ver.indexOf("MSIE"))+1 
brow_ver  = parseFloat(ver.substring(thestart+4,thestart+7)) 
if ((browser=="Microsoft Internet Explorer") && (brow_ver < 10)) # the min. IE ver is set to 10. 
  window.location="/oldie.html"

