# Be sure to restart your server when you modify this file.

Apibrowser::Application.config.session_store :cookie_store, 
                                             :key => '_apibrowser_session',
                                             # set session cookies to expire
                                             :expire_after => 2.hours # See also SessionController if you change this

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Apibrowser::Application.config.session_store :active_record_store
