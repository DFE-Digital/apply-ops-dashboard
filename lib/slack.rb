require 'active_support/all'

module Slack
  class << self
    def post_confused_features(confused_features)
      return unless Date.today.on_weekday?

      if confused_features.empty?
        post(text: '✌️ Feature flags are consistent across Production, Staging and Sandbox')
      else
        message = confused_features.map { |f| "- ‘#{f.name}’" }.join("\n")

        post(text: "😬 Uh-oh! The following feature flags are inconsistent across Production, Staging and Sandbox:\n\n#{message}\n\n<https://apply-ops-dashboard.azurewebsites.net/features|:shipitbeaver: Check the feature flags dashboard>")
      end
    end

    def daily_deployment_message(deployers, prs)
      return unless Date.today.on_weekday?

      if prs.any?
        message = []
        message << "Good afternoon! Today’s deployer is *<@#{deployers[0]['slackUserId']}>*. Reserves are *<@#{deployers[1]['slackUserId']}>* and *<@#{deployers[2]['slackUserId']}>*.\n"
        message << "The following PRs haven’t been deployed yet:\n"

        prs.each do |author, title, pr_number|
          message << "- <https://github.com/DFE-Digital/apply-for-teacher-training/pull/#{pr_number}|#{title}> (#{author})"
        end
      else
        message = ["Good afternoon! Today’s deployer is *<@#{deployers[0]['slackUserId']}>*, but there’s *nothing to deploy* - go out and have an ice cream, *<@#{deployers[0]['slackUserId']}>*!"]
      end

      post(text: message.join("\n"), channel: '#twd_apply_tech')
    end

    def post_prs_being_deployed(prs, target_environment)
      if target_environment == 'production'
        message = ':ship_it_parrot: The above PRs are now being deployed to *production*'
      else
        message = "The following PRs are being deployed to *#{target_environment}*:\n\n"

        prs.map do |author, title, pr_number|
          message << "- <https://github.com/DFE-Digital/apply-for-teacher-training/pull/#{pr_number}|#{title}> (#{author})\n"
        end
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
