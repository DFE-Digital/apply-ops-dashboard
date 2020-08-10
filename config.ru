require File.expand_path('app', File.dirname(__FILE__))
require File.expand_path('api', File.dirname(__FILE__))

run Rack::URLMap.new({
  '/' => MyApp,
  '/webhooks' => MyApi,
})
