require 'active_support/all'

module Slack
  class << self
    def post_deployers_for_today(deployers)
      return unless Date.today.on_weekday?

      post(text: "Today’s deployer is *<@#{deployers[0]['slackUserId']}>*.\n\nReserves: *<@#{deployers[1]['slackUserId']}>* and *<@#{deployers[2]['slackUserId']}>*")
    end

    def post_confused_features(confused_features)
      return unless Date.today.on_weekday?

      if confused_features.empty?
        post(text: '✌️ Feature flags are consistent across Production, Staging and Sandbox')
      else
        message = confused_features.map { |f| "- '#{f.name}'" }.join("\n")

        post(text: "😬 Uh-oh! The following feature flags are inconsistent across Production, Staging and Sandbox:\n\n#{message}\n\n<https://apply-ops-dashboard.azurewebsites.net/features|:shipitbeaver: Check the feature flags dashboard>")
      end
    end

    def post_undeployed_prs(prs)
      return unless Date.today.on_weekday? && prs.any?

      message = prs.reduce("The following PRs haven’t been deployed yet:\n") do |str, (author, title)|
        str + "\n- #{title} (#{author})"
      end

      post(text: message)
    end

    def post_prs_being_deployed(prs, target_environment)
      message = prs.reduce("The following PRs are being deployed to *#{target_environment}* :ship_it_parrot:\n") do |str, (author, title, pr_number)|
        str + "- <https://github.com/DFE-Digital/apply-for-teacher-training/pull/#{pr_number}|#{title}> (#{author})\n"
      end
      post(text: message, channel: '#twd_apply')
    end

  private

    def post(text: '', channel: '#twd_apply_tech')
      payload = {
        username: 'Apply ops dashboard',
        icon_emoji: ':train-beaver:',
        channel: channel,
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
