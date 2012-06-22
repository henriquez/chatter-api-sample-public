// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap.min
//= require twitter/bootstrap-tooltip
//= require twitter/bootstrap-popover
//= require twitter/bootstrap-alert
//= require twitter/bootstrap-dropdown
//= require underscore-min
//= require home
//= require jquery-elastic
//= require jquery-input-event
//= require jquery-mentions
//= require jquery-cookie
//= require sugar-dates
//= require chatter

// main is where we init global stuff
//= require main
//= require navbar 

// all rendering templates you want to load must be listed here
//= require templates/chatter/feeds.jst.eco
//= require templates/chatter/feed_item.jst.eco
//= require templates/chatter/comment_publisher.jst.eco
//= require templates/chatter/comment.jst.eco

// Careful of the order! bootstrap must come before the files that
// call it.  jquery-input-event is required before jquery-mentions because
// it provides IE8 polyfil event emulation.  The above must come before any
// custom scripts

// Note that component, controller/page specific scripts are loaded in their
// respective view files via the <% javascript 'name_of_the_js_file' %>
// erb helper.  All of these must be specified inside config/application.rb
// in order to be compiled in production mode.
// e.g config.assets.precompile += %w('chatter-feed.js', 'chatter-publisher.js')



