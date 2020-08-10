require 'sinatra'
require 'jwt'
require_relative 'lib/notify'

class MyApi < Sinatra::Base
  before do
    halt 401 if request.env['HTTP_AUTHORIZATION'].nil?
    acces_token = request.env['HTTP_AUTHORIZATION'].slice(7..-1)
    JWT.decode acces_token, public_key, true, { algorithm: 'RS256' }
  rescue StandardError
    halt 403
  end

  post '/deploy-in-progress' do
    halt 404 if params['target_environment'].nil?
    halt 422 if params['target_environment'] != 'staging' && params['target_environment'] != 'production'
    Notify.prs_being_deployed(params['target_environment'])
    204
  end

  def public_key
    @public_key ||= OpenSSL::PKey::RSA.new File.read('public_key')
  end
end
