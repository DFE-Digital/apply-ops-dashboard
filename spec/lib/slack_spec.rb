require_relative '../../lib/slack'

RSpec.describe Slack do
  around do |ex|
    ClimateControl.modify SLACK_WEBHOOK_URL: 'https://example.com' do
      ex.run
    end
  end

  describe '.post_deployers_for_today' do
    it 'sends a message to slack' do
      deployers = %w[A B C]

      slack_request = stub_request(:post, 'https://example.com')

      Slack.post_deployers_for_today(deployers)

      expect(slack_request.with(body: hash_including(text: 'Today’s deployer is *A*. Reserves: *B*, *C*')))
        .to have_been_made
    end
  end
end
