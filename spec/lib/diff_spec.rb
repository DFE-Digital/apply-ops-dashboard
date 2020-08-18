require_relative '../../lib/github'
require_relative '../../lib/diff'

RSpec.describe Diff do
  describe '.pull_requests_between' do
    it 'extracts the correct titles, authors, and PR numbers' do
      VCR.use_cassette('github-diff', record: :once) do
        compare = Diff.pull_requests_between('master', '0efbef5707db151b128015c710011b8685b3485b')

        expect(compare.first).to eql(['Paul Robert Lloyd', 'Avoid negative contractions', '2698'])
      end
    end
  end
end
