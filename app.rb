require 'sinatra'
require 'sinatra/cookies'
require_relative 'lib/state'
require_relative 'lib/features'

class MyApp < Sinatra::Base
  helpers Sinatra::Cookies
  set :cookie_options, path: '/'

  get '/' do
    erb :index, locals: { state: State.new }
  end

  get '/features' do
    @features = Features.new
    @sorted_features = @features.all.sort_by { |f| %w[confused shipping ok].index(f.state) }
    erb :features
  end

  get '/login' do
    params.each { |k, v| cookies[k] = v }
    redirect "/?login=success&deploy=true&environment=#{params[:environment]}&commit_sha=#{params[:commit_sha]}&state=#{params[:state]}"
  end
end
