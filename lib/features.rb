class Features
  def all
    prod = feature_flags_for('www')
    staging = feature_flags_for('staging')
    sandbox = feature_flags_for('sandbox')
    qa = feature_flags_for('qa')

    feature_ids = (qa['feature_flags'].keys + staging['feature_flags'].keys + prod['feature_flags'].keys + sandbox['feature_flags'].keys).uniq
    feature_ids.map do |id|
      Feature.new(
        name: qa.dig('feature_flags', id, 'name'),
        production: prod.dig('feature_flags', id, 'active') || false,
        staging: staging.dig('feature_flags', id, 'active') || false,
        sandbox: sandbox.dig('feature_flags', id, 'active') || false,
        qa: qa.dig('feature_flags', id, 'active') || false,
      )
    end
  end

  def feature_flags_for(env)
    JSON.parse(HTTP.get("https://#{env}.apply-for-teacher-training.education.gov.uk/integrations/feature-flags"))
  end

  class Feature
    attr_reader :name, :production, :staging, :sandbox, :qa

    def initialize(name:, production:, staging:, sandbox:, qa:)
      @name = name
      @production = production
      @sandbox = sandbox
      @staging = staging
      @qa = qa
    end

    def state
      if [production, sandbox, staging, qa].all?
        'ok'
      elsif [production, sandbox, staging, qa].none?
        'ok'
      elsif qa && [production, sandbox, staging].none?
        'shipping'
      else
        'confused'
      end
    end
  end
end
