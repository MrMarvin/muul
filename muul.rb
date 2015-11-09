require 'sinatra'
require 'rack/reverse_proxy'

require './authenticator'

module Muul
  module AppHelper
    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="MUUL protected Marathon. Authentication required!")
        halt 401, "Not authorized\n"
      end
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && Authenticator.new.valid?(@auth.credentials)
    end
  end

  class App < Sinatra::Base
    include AppHelper
    def self.all_verbs(url,&block)
      get(url,&block)
      post(url,&block)
      put(url,&block)
      delete(url,&block)
      head(url,&block)
      options(url,&block)
    end

    get '/' do
      return 200, "ok"
    end

    get '/api' do
      protected!
      return 200, "this is a protected API."
    end

    all_verbs '/proxy/*' do
      protected!
      proxy = Rack::ReverseProxy.new do
        reverse_proxy /^\/proxy(\/.*)$/, ENV['MUUL_MARATHON_URL']+'$1'#, username: 'name', password: 'basic_auth_secret'
      end
      ret = proxy.call(request.env)
      puts ret.inspect if ENV["DEBUG"]
      return ret
    end

  end
end