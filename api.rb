require 'sinatra'
require 'jwt'
require 'http'
require 'active_support/core_ext/hash/indifferent_access'
require_relative 'lib/notify'

class MyApi < Sinatra::Base
  before do
    halt 401 if request.env['HTTP_AUTHORIZATION'].nil?
    access_token = request.env['HTTP_AUTHORIZATION'].slice(7..-1)
    JWT.decode access_token, nil, true, { algorithm: 'RS256', jwks: ->(options) { jwks(options) } }
  rescue StandardError
    halt 403
  end

  post '/deploy-in-progress' do
    halt 404 if params['target_environment'].nil?
    halt 422 if params['target_environment'] != 'sandbox' && params['target_environment'] != 'production'
    Notify.prs_being_deployed(params['target_environment'])
    204
  end

  def jwks(options)
    @jwks = nil if options[:invalidate] # need to reload the keys
    @jwks ||= JSON.parse(HTTP.get('https://login.microsoftonline.com/9c7d9dd3-840c-4b3f-818e-552865082e16/discovery/v2.0/keys')).with_indifferent_access
  end
end
