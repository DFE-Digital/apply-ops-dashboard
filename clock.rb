require 'clockwork'
require 'active_support/time'
require_relative 'lib/notify'

module Clockwork
  every(1.day, 'Notify.undeployed_prs', at: '9:30') { Notify.undeployed_prs }
  every(1.day, 'Notify.inconsistent_feature_flags', at: '12:00') { Notify.inconsistent_feature_flags }
  every(1.day, 'Notify.todays_deployers', at: ['10:00', '14:00']) { Notify.todays_deployers }
end
