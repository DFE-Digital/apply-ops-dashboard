require_relative 'feature'

class Features
  def all
    prod, staging, sandbox, qa = environment_states.values_at :production, :staging, :sandbox, :qa

    feature_ids = (qa['feature_flags'].keys + staging['feature_flags'].keys + prod['feature_flags'].keys + sandbox['feature_flags'].keys).uniq

    feature_ids.map do |id|
      # get the name of the feature from whichever environment knows it
      fields = [prod, staging, sandbox, qa].each_with_object({}) do |env, hash|
        hash[:name] ||= env.dig('feature_flags', id, 'name')
        hash[:type] ||= env.dig('feature_flags', id, 'type')
      end

      Feature.new(
        name: fields[:name],
        type: fields[:type],
        production: bool_to_state(prod.dig('feature_flags', id, 'active')),
        staging: bool_to_state(staging.dig('feature_flags', id, 'active')),
        sandbox: bool_to_state(sandbox.dig('feature_flags', id, 'active')),
        qa: bool_to_state(qa.dig('feature_flags', id, 'active')),
      )
    end
  end

  def environment_url(e)
    prefix = environment_attributes[e][:prefix]
    "https://#{prefix}.apply-for-teacher-training.service.gov.uk"
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
end
