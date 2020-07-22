require_relative '../../lib/features'

RSpec.describe Features do
  before do
    stub_const('EXAMPLE_JSON', File.read('spec/examples/features.json'))
    stub_const('ENVS', %w[qa www staging sandbox].freeze)
  end

  it 'constructs an mapping for each feature' do
    ENVS.each do |env|
      stub_request(:get, "https://#{env}.apply-for-teacher-training.service.gov.uk/integrations/feature-flags")
        .to_return(body: EXAMPLE_JSON)
    end

    result = Features.new.all

    expect(result).to all be_a(Feature)
    expect(result.count).to eq 12
  end

  it 'handles a feature which is present on qa but not on other envs' do
    standard_json = EXAMPLE_JSON

    json_with_a_new_flag = JSON.parse(EXAMPLE_JSON)
    json_with_a_new_flag['feature_flags']['killer_robots'] = { 'name' => 'Killer robots', 'active' => true }

    (ENVS - %w[qa]).each do |env|
      stub_request(:get, "https://#{env}.apply-for-teacher-training.service.gov.uk/integrations/feature-flags")
        .to_return(body: standard_json)
    end

    stub_request(:get, 'https://qa.apply-for-teacher-training.service.gov.uk/integrations/feature-flags')
      .to_return(body: json_with_a_new_flag.to_json)

    result = Features.new.all

    new_feature = result.find { |f| f.name == 'Killer robots' }
    expect(new_feature.qa).to eql 'active'
    expect(new_feature.production).to eql 'not_deployed'
    expect(new_feature.staging).to eql 'not_deployed'
    expect(new_feature.sandbox).to eql 'not_deployed'
  end

  it 'handles a feature which is present on non-qa envs but not on qa' do
    standard_json = EXAMPLE_JSON

    json_with_a_new_flag = JSON.parse(EXAMPLE_JSON)
    json_with_a_new_flag['feature_flags']['killer_robots'] = { 'name' => 'Killer robots', 'active' => true }

    (ENVS - %w[www]).each do |env|
      stub_request(:get, "https://#{env}.apply-for-teacher-training.service.gov.uk/integrations/feature-flags")
        .to_return(body: standard_json)
    end

    stub_request(:get, 'https://www.apply-for-teacher-training.service.gov.uk/integrations/feature-flags')
      .to_return(body: json_with_a_new_flag.to_json)

    result = Features.new.all

    new_feature = result.find { |f| f.name == 'Killer robots' }

    expect(new_feature.qa).to eql 'not_deployed'
    expect(new_feature.production).to eql 'active'
    expect(new_feature.staging).to eql 'not_deployed'
    expect(new_feature.sandbox).to eql 'not_deployed'
  end

  describe '#sandbox_environments' do
    it 'returns a correct list of environments' do
      sandbox_mode_json = JSON.parse(EXAMPLE_JSON)
      sandbox_mode_json['sandbox_mode'] = true

      %w[www staging].each do |env|
        stub_request(:get, "https://#{env}.apply-for-teacher-training.service.gov.uk/integrations/feature-flags")
          .to_return(body: EXAMPLE_JSON)
      end

      %w[qa sandbox].each do |env|
        stub_request(:get, "https://#{env}.apply-for-teacher-training.service.gov.uk/integrations/feature-flags")
          .to_return(body: sandbox_mode_json.to_json)
      end

      result = Features.new.sandbox_environments

      expect(result).to match_array %i[qa sandbox]
    end
  end
end
