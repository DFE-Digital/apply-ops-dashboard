require 'spec_helper'
require 'features'
require 'webmock/rspec'

RSpec.describe Features do
  EXAMPLE_JSON = File.read('spec/examples/features.json')
  ENVS = %w{qa www staging sandbox}

  it 'constructs an mapping for each feature' do
    ENVS.each do |env|
      stub_request(:get, "https://#{env}.apply-for-teacher-training.education.gov.uk/integrations/feature-flags")
        .to_return(body: EXAMPLE_JSON)
    end

    result = Features.new.all

    expect(result).to all be_a(Features::Feature)
    expect(result.count).to eq 15
  end

  it 'handles a feature which is present on qa but not on other envs' do
    standard_json = EXAMPLE_JSON

    json_with_a_new_flag = JSON.parse(EXAMPLE_JSON)
    json_with_a_new_flag["feature_flags"]["killer_robots"] = {"name" => "Killer robots", "active" => true }

    (ENVS - ['qa']).each do |env|
      stub_request(:get, "https://#{env}.apply-for-teacher-training.education.gov.uk/integrations/feature-flags")
        .to_return(body: standard_json)
    end

    stub_request(:get, 'https://qa.apply-for-teacher-training.education.gov.uk/integrations/feature-flags')
      .to_return(body: json_with_a_new_flag.to_json)

    result = Features.new.all

    new_feature = result.find { |f| f.name == "Killer robots" }
    expect(new_feature.qa).to be true
    expect(new_feature.production).to be false
    expect(new_feature.staging).to be false
    expect(new_feature.sandbox).to be false
  end
end
