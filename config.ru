require 'dotenv'
Dotenv.load

GEMINABOX_USERNAME = ENV['GEMINABOX_USERNAME']
GEMINABOX_PASSWORD = ENV['GEMINABOX_PASSWORD']
fail 'cannot find credentials' unless GEMINABOX_USERNAME && GEMINABOX_PASSWORD

# fix warning
# WARN: tilt autoloading 'tilt/erb' in a non thread-safe way; explicit require 'tilt/erb' suggested.
require 'tilt/erb'

require 'geminabox'
require 'newrelic_rpm' if ENV['NEWRELIC_LICENSE_KEY']

Geminabox.data = ENV['GEMINABOX_DATA'] || File.expand_path('../data', __FILE__)

# https://github.com/geminabox/geminabox/wiki/Http-Basic-Auth
Geminabox::Server.helpers do
  def protected!
    return if authorized?
    response['WWW-Authenticate'] = 'Basic realm="Geminabox"'
    halt 401, "No pushing or deleting without auth.\n"
  end

  def authorized?
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [GEMINABOX_USERNAME, GEMINABOX_PASSWORD]
  end
end

Geminabox::Server.before '/upload' do
  protected!
end

Geminabox::Server.before do
  protected! if request.delete?
end

run Geminabox::Server
