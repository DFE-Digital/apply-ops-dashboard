require_relative '../app'

RSpec.describe 'The Apply Ops Dashboard' do
  include Rack::Test::Methods

  def app
    MyApp
  end

  it 'works' do
    VCR.use_cassette('github-repo-without-hotfix-branch') do
      VCR.use_cassette('full-page-request') do
        get '/'
      end
    end

    expect(last_response).to be_ok
  end
end
