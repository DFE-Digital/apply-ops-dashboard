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
