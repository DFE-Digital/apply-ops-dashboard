class Deployers
  def self.for_today
    if ENV['DEPLOYERS']
      seed = Time.new.strftime('%-d%m%y').to_i
      JSON.parse(ENV['DEPLOYERS']).shuffle(random: Random.new(seed))
    else
      []
    end
  end
end
