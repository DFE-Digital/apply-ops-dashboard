require_relative 'lib/state'
require_relative 'lib/slack'
require_relative 'lib/features'
require_relative 'lib/diff'

namespace :slack do
  desc 'Post today\'s deployers to slack'
  task :post_deployers_for_today do
    state = State.new
    Slack.post_deployers_for_today(state.deployers_for_today)
  end

  desc 'Post confused feature flags message to slack'
  task :post_confused_features do
    confused_features = Features.new.all.select { |f| f.state == 'confused' }
    Slack.post_confused_features(confused_features)
  end

  desc 'Post undeployed PRs change log to slack'
  task :post_undeployed_prs do
    state = State.new
    prs = Diff.pull_requests_between(state.latest_successfull_build_to('qa').commit_sha, state.latest_successfull_build_to('production').commit_sha)
    Slack.post_undeployed_prs(prs)
  end
end
