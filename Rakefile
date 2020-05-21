require_relative 'lib/state'
require_relative 'lib/slack'

namespace :slack do
  task :post_deployers_for_today do
    state = State.new
    Slack.post_deployers_for_today(state.deployers_for_today)
  end
end
