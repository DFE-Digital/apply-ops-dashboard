require_relative 'lib/notify'

namespace :slack do
  desc 'Post confused feature flags message to slack'
  task :post_confused_features do
    Notify.inconsistent_feature_flags
  end

  desc 'Post the daily deployment message to Slack'
  task :daily_deployment_message do
    Notify.daily_deployment_message
  end

  desc 'Post PRs being deployed'
  task :post_prs_being_deployed do
    Notify.prs_being_deployed('staging')
    Notify.prs_being_deployed('production')
  end
end
