require 'sinatra'
require_relative 'lib/state'
require_relative 'lib/features'

class MyApp < Sinatra::Base
  get '/' do
    erb :index, locals: { state: State.new }
  end

  get '/features' do
    erb :features
  end
end
