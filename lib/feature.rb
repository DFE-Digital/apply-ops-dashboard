class Feature
  attr_reader :name, :type, :production, :staging, :sandbox, :qa

  # rubocop:disable Naming/MethodParameterName
  def initialize(name:, type:, production:, staging:, sandbox:, qa:)
    @name = name
    @type = type
    @production = production
    @sandbox = sandbox
    @staging = staging
    @qa = qa
  end
  # rubocop:enable Naming/MethodParameterName

  def state
    if type == 'variant'
      'ok'
    elsif [production, sandbox, staging, qa].uniq == %w[active]
      'ok'
    elsif [production, sandbox, staging, qa].uniq == %w[inactive]
      'ok'
    elsif [production, sandbox, staging].include?('not_deployed')
      'ok'
    elsif qa == 'active' && [production, sandbox, staging].uniq == %w[inactive]
      'shipping'
    else
      'confused'
    end
  end
end
