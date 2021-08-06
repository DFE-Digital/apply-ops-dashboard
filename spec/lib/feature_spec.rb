require_relative '../../lib/feature'

RSpec.describe Feature do
  describe '#state' do
    it 'is "ok" when feature is variant' do
      f = Feature.new(
        name: 'X',
        type: 'variant',
        production: 'active',
        staging: 'inactive',
        qa: 'inactive',
        sandbox: 'inactive',
      )

      expect(f.state).to eq 'ok'
    end

    it 'is "ok" when everything is active' do
      f = Feature.new(
        name: 'X',
        type: 'invariant',
        production: 'active',
        staging: 'active',
        qa: 'active',
        sandbox: 'active',
      )

      expect(f.state).to eq 'ok'
    end

    it 'is "ok" when everything is inactive' do
      f = Feature.new(
        name: 'X',
        type: 'invariant',
        production: 'inactive',
        staging: 'inactive',
        qa: 'inactive',
        sandbox: 'inactive',
      )

      expect(f.state).to eq 'ok'
    end

    it 'is "confused" when some things are active and some inactive' do
      f = Feature.new(
        name: 'X',
        type: 'invariant',
        production: 'active',
        staging: 'inactive',
        qa: 'inactive',
        sandbox: 'inactive',
      )

      expect(f.state).to eq 'confused'
    end

    it 'is "shipping" if qa is active and the rest inactive' do
      f = Feature.new(
        name: 'X',
        type: 'invariant',
        production: 'inactive',
        staging: 'inactive',
        qa: 'active',
        sandbox: 'inactive',
      )

      expect(f.state).to eq 'shipping'
    end

    it 'is "ok" if any of the environments have not been deployed yet' do
      f = Feature.new(
        name: 'X',
        type: 'invariant',
        production: 'not_deployed',
        staging: 'not_deployed',
        qa: 'inactive',
        sandbox: 'not_deployed',
      )

      expect(f.state).to eq 'ok'
    end
  end
end
