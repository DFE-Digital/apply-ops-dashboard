require 'sinatra'
require 'sinatra/cookies'
require 'jwt'
require 'http'
require 'octokit'
require 'active_support/core_ext/hash/indifferent_access'
require_relative 'lib/notify'
require_relative 'lib/github'

class MyApi < Sinatra::Base
  helpers Sinatra::Cookies
  set :cookie_options, path: '/'

  post '/trigger-deployment' do
    halt 401 if cookies['code'].nil?
    halt 401 if cookies['state'].nil? || cookies['state'] != ENV['GITHUB_STATE']
    halt 422 if cookies['environment'] != 'sandbox' && cookies['environment'] != 'production'

    response = Octokit.exchange_code_for_token(cookies['code'], ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET'])
    halt 403 if response.error?

    github_client = Octokit::Client.new(access_token: response.access_token)
    triggered = GitHub.trigger_deploy_workflow_run(github_client, cookies['commit_sha'], cookies['environment'])

    halt 500 unless triggered
    cookies.clear
    Notify.prs_being_deployed(cookies['environment'])
    204
  end
end
