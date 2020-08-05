require_relative '../../lib/deployers'

RSpec.describe Deployers do
  around do |ex|
    ClimateControl.modify DEPLOYERS: '[{"name":"One","userId":"1"},{"name":"Two","userId":"2"},{"name":"Three","userId":"3"},{"name":"Four","userId":"4"},{"name":"Five","userId":"5"}]' do
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
