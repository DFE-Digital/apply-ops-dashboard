require_relative '../../lib/state'

RSpec.describe State do
  context 'a deploy to production failed' do
    it 'reports the correct data' do
      VCR.use_cassette('deploy-to-production-failed') do
        state = State.new

        expect(state.main_broken?).to be true
        expect(state.deploy_to_production_failed?).to be true
        expect(state.deploying_to_production?).to be false
      end
    end
  end

  context 'a latest successfull deploy to production' do
    it 'reports the correct data' do
      VCR.use_cassette('latest-successfull-deploy') do
        state = State.new
        expect(state.latest_successfull_build_to('production').commit_sha).to eql('2992892343623e101efd9e6686229cfc066ac6c5')
      end
    end
  end

  context 'a deploy to production in progress' do
    it 'reports the correct data' do
      VCR.use_cassette('deploy-to-production-in-progress') do
        state = State.new

        expect(state.deploy_to_production_failed?).to be false
        expect(state.deploying_to_production?).to be true
      end
    end
  end

  describe '#hotfix_in_progress?' do
    context 'The Github repo contains a hotfix branch' do
      it 'returns true' do
        VCR.use_cassette('github-repo-with-hotfix-branch') do
          state = State.new

          expect(state.hotfix_in_progress?).to be true
        end
      end
    end

    context 'The Github repo does not contain a hotfix branch' do
      it 'returns false' do
        VCR.use_cassette('github-repo-without-hotfix-branch') do
          state = State.new

          expect(state.hotfix_in_progress?).to be false
        end
      end
    end
  end
end
