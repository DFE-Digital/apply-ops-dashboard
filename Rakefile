require_relative 'lib/notify'

namespace :slack do
  desc 'Post today\'s deployers to slack'
  task :post_deployers_for_today do
    Notify.todays_deployers
  end

  desc 'Post confused feature flags message to slack'
  task :post_confused_features do
    Notify.undeployed_prs
  end

  desc 'Post undeployed PRs change log to slack'
  task :post_undeployed_prs do
    Notify.inconsistent_feature_flags
  end
end
