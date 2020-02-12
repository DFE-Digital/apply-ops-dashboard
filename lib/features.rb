class Features
  def all
    prod = get('www')
    staging = get('staging')
    sandbox = get('sandbox')
    qa = get('qa')

    feature_ids = (qa['feature_flags'].keys + staging['feature_flags'].keys + prod['feature_flags'].keys + sandbox['feature_flags'].keys).uniq
    feature_ids.map do |id|
      Feature.new(
        name: qa['feature_flags'][id]['name'],
        production: prod['feature_flags'][id]['active'],
        staging: staging['feature_flags'][id]['active'],
        sandbox: sandbox['feature_flags'][id]['active'],
        qa: qa['feature_flags'][id]['active'],
      )
    end
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

  def get(env)
    JSON.parse(HTTP.get("https://#{env}.apply-for-teacher-training.education.gov.uk/integrations/feature-flags"))
  end
end
