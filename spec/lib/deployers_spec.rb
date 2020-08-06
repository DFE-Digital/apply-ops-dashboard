require_relative '../../lib/deployers'

RSpec.describe Deployers do
  around do |ex|
    ClimateControl.modify DEPLOYERS: '[{"displayName":"One","slackUserId":"1"},{"displayName":"Two","slackUserId":"2"},{"displayName":"Three","slackUserId":"3"},{"displayName":"Four","slackUserId":"4"},{"displayName":"Five","slackUserId":"5"}]' do
      ex.run
    end
  end

  describe '.for_today' do
    it 'always returns the same value on the same day' do
      Timecop.travel(2019, 1, 1) do
        deployers_for_today = Array.new(10) { Deployers.for_today }
        expect(deployers_for_today.uniq.count).to eq 1
      end
    end

    it 'returns different values on different days' do
      deployers_for_jan1 = nil
      deployers_for_jan2 = nil

      Timecop.travel(2019, 1, 1) do
        deployers_for_jan1 = Deployers.for_today
      end
      Timecop.travel(2019, 1, 2) do
        deployers_for_jan2 = Deployers.for_today
      end

      expect(deployers_for_jan1).not_to eq(deployers_for_jan2)
    end
  end
end
