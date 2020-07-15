require_relative 'lib/state'
require_relative 'lib/slack'
require_relative 'lib/features'
require_relative 'lib/diff'

namespace :slack do
  task :post_deployers_for_today do
    state = State.new
    Slack.post_deployers_for_today(state.deployers_for_today)
  end

  task :post_confused_features do
    confused_features = Features.new.all.select { |f| f.state == 'confused' }
    Slack.post_confused_features(confused_features)
  end

  task :post_undeployed_prs do
    prs = Diff.pull_requests_between(state.latest_successfull_build_to('qa').commit_sha, state.latest_successfull_build_to('production').commit_sha)
    Slack.post_undeployed_prs(prs)
  end
end
