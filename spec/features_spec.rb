require 'spec_helper'
require 'features'
require 'webmock/rspec'

RSpec.describe Features do
  EXAMPLE_JSON = File.read('spec/examples/features.json')

  it 'constructs an mapping for each feature' do
    envs = %w{www staging sandbox qa}
    envs.each do |env|
      stub_request(:get, "https://#{env}.apply-for-teacher-training.education.gov.uk/integrations/feature-flags")
        .to_return(body: EXAMPLE_JSON)
    end

    result = Features.new.all

    expect(result).to all be_a(Features::Feature)
    expect(result.count).to eq 15
  end
end
