require 'vcr'
require 'state'

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
end

RSpec.describe State do
  it 'works' do
    VCR.use_cassette("deploy-to-production-failed") do
      state = State.new

      state.latest_deploy_to('production')
      state.latest_deploy_to('qa')
    end
  end
end
