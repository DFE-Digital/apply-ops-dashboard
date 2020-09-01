require_relative '../../lib/slack'
require_relative '../../lib/feature'

RSpec.describe Slack do
  around do |ex|
    ClimateControl.modify SLACK_WEBHOOK_URL: 'https://example.com' do
      ex.run
    end
  end

  describe '.daily_deployment_message' do
    it 'sends a message to slack' do
      slack_request = stub_request(:post, 'https://example.com')

      deployers = JSON.parse('[{"displayName":"One","slackUserId":"1"},{"displayName":"Two","slackUserId":"2"},{"displayName":"Three","slackUserId":"3"}]')

      undeployed = [
        ['Alice', 'Fix a bug'],
        ['Bob', 'Ship a feature'],
      ]

      Timecop.freeze('2020-05-27') do
        Slack.daily_deployment_message(deployers, undeployed)
      end

      expect(slack_request.with(body: hash_including(text: "Good afternoon! Today’s deployer is *\u003c@1\u003e*. Reserves are *\u003c@2\u003e* and *\u003c@3\u003e*.\n\nThe following PRs haven’t been deployed yet:\n\n- \u003chttps://github.com/DFE-Digital/apply-for-teacher-training/pull/|Fix a bug\u003e (Alice)\n- \u003chttps://github.com/DFE-Digital/apply-for-teacher-training/pull/|Ship a feature\u003e (Bob)")))
        .to have_been_made
    end

    it 'sends a special message when there are no undeployed PRs' do
      slack_request = stub_request(:post, 'https://example.com')

      deployers = JSON.parse('[{"displayName":"One","slackUserId":"1"},{"displayName":"Two","slackUserId":"2"},{"displayName":"Three","slackUserId":"3"}]')

      Slack.daily_deployment_message(deployers, [])

      expect(slack_request.with(body: hash_including(text: "Good afternoon! Today’s deployer is *\u003c@1\u003e*, but there’s *nothing to deploy* - go out and have an ice cream, *\u003c@1\u003e*!")))
        .to have_been_made
    end

    it 'takes the weekend off' do
      slack_request = stub_request(:post, 'https://example.com')

      Timecop.freeze('2020-05-24') do
        Slack.daily_deployment_message([], [])
      end

      expect(slack_request).not_to have_been_made
    end
  end

  describe '.post_confused_features' do
    it 'sends a message when features are confused' do
      confused_features = [
        Feature.new(name: 'Wonky feature', production: true, staging: false, sandbox: false, qa: false),
      ]

      slack_request = stub_request(:post, 'https://example.com')

      Slack.post_confused_features(confused_features)

      expect(slack_request.with(body: hash_including(text: /Uh-oh!.*?Wonky feature/m)))
        .to have_been_made
    end

    it 'sends a message when features are OK' do
      slack_request = stub_request(:post, 'https://example.com')

      Slack.post_confused_features([])

      expect(slack_request.with(body: hash_including(text: /Feature flags are consistent/)))
        .to have_been_made
    end
  end
end
