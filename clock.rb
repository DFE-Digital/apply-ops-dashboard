require 'clockwork'
require 'active_support/time'
require_relative 'lib/notify'

module Clockwork
  every(1.day, 'Notify.inconsistent_feature_flags', at: '12:00') { Notify.inconsistent_feature_flags }
  every(1.day, 'Notify.daily_deployment_message', at: '14:00') { Notify.daily_deployment_message }
  every(1.day, 'Populate yesterdays deployer', at: '22:00') { File.write('/app/yesterdays_deployer.json', Deployers.for_today(yesterdays_deployer_file: '/app/yesterdays_deployer.json')[0].to_json) }
end
