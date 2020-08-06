require_relative '../../lib/slack'
require_relative '../../lib/feature'

RSpec.describe Slack do
  around do |ex|
    ClimateControl.modify SLACK_WEBHOOK_URL: 'https://example.com' do
      ex.run
    end
  end

  describe '.post_deployers_for_today' do
    it 'sends a message to slack' do
      deployers = JSON.parse('[{"displayName":"One","slackUserId":"1"},{"displayName":"Two","slackUserId":"2"},{"displayName":"Three","slackUserId":"3"}]')

      slack_request = stub_request(:post, 'https://example.com')

      Timecop.freeze('2020-05-27') do
        Slack.post_deployers_for_today(deployers)
      end

      expect(slack_request.with(body: hash_including(text: "Today’s deployer is *\u003c@1\u003e*.\n\nReserves: *\u003c@2\u003e* and *\u003c@3\u003e*")))
        .to have_been_made
    end

    it 'takes the weekend off' do
      deployers = %w[A B C]

      slack_request = stub_request(:post, 'https://example.com')

      Timecop.freeze('2020-05-24') do
        Slack.post_deployers_for_today(deployers)
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

  describe '.post_undeployed_prs' do
    it 'sends a message when there are undeployed PRs' do
      slack_request = stub_request(:post, 'https://example.com')

      undeployed = [
        ['Alice', 'Fix a bug'],
        ['Bob', 'Ship a feature'],
      ]

      Slack.post_undeployed_prs(undeployed)

      expect(slack_request.with(body: hash_including(text: /The following PRs.*?Fix a bug \(Alice\)/m)))
        .to have_been_made
    end

    it 'sends no message when there are no undeployed PRs' do
      slack_request = stub_request(:post, 'https://example.com')

      Slack.post_undeployed_prs([])

      expect(slack_request).not_to have_been_made
    end
  end
end
