require 'active_support/all'

module Slack
  class << self
    def post_deployers_for_today(deployers)
      return unless Date.today.on_weekday?

      post(text: "Today’s deployer is *#{deployers[0]}*. Reserves: *#{deployers[1]}*, *#{deployers[2]}*")
    end

    def post_confused_features(confused_features)
      return unless Date.today.on_weekday?

      return if confused_features.empty?

      message = confused_features.map { |f| "- '#{f.name}'" }.join("\n")

      post(text: "😬 Uh-oh! The following feature flags are inconsistent across Production, Staging and Sandbox:\n\n#{message}\n\n<https://apply-ops-dashboard.herokuapp.com/features|:shipitbeaver: Check the feature flags dashboard>")
    end

  private

    def post(text:)
      payload = {
        username: 'Apply ops dashboard',
        icon_emoji: ':train-beaver:',
        channel: '#twd_apply_tech',
        text: text,
        mrkdwn: true,
      }

      if ENV['DRY_RUN']
        puts YAML.dump(payload)
      else
        HTTP[content_type: 'application/json']
          .post(webhook_url, body: payload.to_json)
      end
    end

    def webhook_url
      ENV.fetch('SLACK_WEBHOOK_URL')
    end
  end
end
