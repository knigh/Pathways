# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_lifePathways_session',
  :secret      => '8adbaa959916f64e03177bf160eabb455f5aa9e78a9a242bb56880bce4a3fd9b96ccb895c39ddcd0e4e71055489a863b7291eb59ddf0713e5f14828dbf1b2ce5'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
