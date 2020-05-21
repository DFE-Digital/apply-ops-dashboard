class Features
  def all
    prod, staging, sandbox, qa = environment_states.values_at :production, :staging, :sandbox, :qa

    feature_ids = (qa['feature_flags'].keys + staging['feature_flags'].keys + prod['feature_flags'].keys + sandbox['feature_flags'].keys).uniq

    feature_ids.map do |id|
      # get the name of the feature from whichever environment knows it
      name = [prod, staging, sandbox, qa].map { |env| env.dig('feature_flags', id, 'name') }.reject(&:nil?).first

      Feature.new(
        name: name,
        production: bool_to_state(prod.dig('feature_flags', id, 'active')),
        staging: bool_to_state(staging.dig('feature_flags', id, 'active')),
        sandbox: bool_to_state(sandbox.dig('feature_flags', id, 'active')),
        qa: bool_to_state(qa.dig('feature_flags', id, 'active')),
      )
    end
  end

  def environment_url(e)
    prefix = environment_attributes[e][:prefix]
    "https://#{prefix}.apply-for-teacher-training.education.gov.uk"
  end

  def environment_name(e)
    environment_attributes[e][:name]
  end

  def environment_attributes
    {
      production: { name: 'Production', prefix: 'www' },
      staging: { name: 'Staging', prefix: 'staging' },
      sandbox: { name: 'Sandbox', prefix: 'sandbox' },
      qa: { name: 'QA', prefix: 'qa' },
    }
  end

  def sandbox_environments
    environment_states.each_with_object([]) do |(environment, state), list|
      list.push environment if state['sandbox_mode']
    end
  end

  def environment_states
    @environment_states ||= {
      production: feature_flags_for(:production),
      staging: feature_flags_for(:staging),
      sandbox: feature_flags_for(:sandbox),
      qa: feature_flags_for(:qa),
    }
  end

  def feature_flags_for(e)
    JSON.parse(HTTP.get("#{environment_url(e)}/integrations/feature-flags"))
  end

  def bool_to_state(bool_or_nil)
    if bool_or_nil.nil?
      'not_deployed'
    elsif bool_or_nil
      'active'
    else
      'inactive'
    end
  end

  class Feature
    attr_reader :name, :production, :staging, :sandbox, :qa

    # rubocop:disable Naming/MethodParameterName
    def initialize(name:, production:, staging:, sandbox:, qa:)
      @name = name
      @production = production
      @sandbox = sandbox
      @staging = staging
      @qa = qa
    end
    # rubocop:enable Naming/MethodParameterName

    def state
      if [production, sandbox, staging, qa].uniq == %w[active]
        'ok'
      elsif [production, sandbox, staging, qa].uniq == %w[inactive]
        'ok'
      elsif qa == 'active' && [production, sandbox, staging].uniq == %w[inactive]
        'shipping'
      else
        'confused'
      end
    end
  end
end
