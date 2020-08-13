require_relative 'state'
require_relative 'slack'
require_relative 'features'
require_relative 'diff'

class Notify
  def self.todays_deployers
    state = State.new
    Slack.post_deployers_for_today(state.deployers_for_today)
  end

  def self.undeployed_prs
    state = State.new
    prs = Diff.pull_requests_between(state.latest_successfull_build_to('qa').commit_sha, state.latest_successfull_build_to('production').commit_sha)
    Slack.post_undeployed_prs(prs)
  end

  def self.inconsistent_feature_flags
    confused_features = Features.new.all.select { |f| f.state == 'confused' }
    Slack.post_confused_features(confused_features)
  end

  def self.prs_being_deployed(target_environment)
    state = State.new
    from_environment = target_environment == 'staging' ? 'qa' : 'staging'
    prs = Diff.pull_requests_between(state.latest_successfull_build_to(from_environment).commit_sha, state.latest_successfull_build_to(target_environment).commit_sha)
    Slack.post_prs_being_deployed(prs, target_environment) unless prs.empty?
  end
end
