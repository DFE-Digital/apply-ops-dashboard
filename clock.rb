require 'clockwork'
require 'active_support/time'
require_relative 'lib/notify'

module Clockwork
  every(1.day, 'Notify.inconsistent_feature_flags', at: '12:00') { Notify.inconsistent_feature_flags }
  every(1.day, 'Daily deployment message', at: ['14:00']) { Notify.daily_deployment_message }
end
