module Slack
  class << self
    def post_deployers_for_today(deployers)
      return unless Date.today.on_weekday?

      post(text: "Today’s deployer is *#{deployers[0]}*. Reserves: *#{deployers[1]}*, *#{deployers[2]}*")
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

      HTTP[content_type: 'application/json']
        .post(webhook_url, body: payload.to_json)
    end

    def webhook_url
      ENV.fetch('SLACK_WEBHOOK_URL')
    end
  end
end
