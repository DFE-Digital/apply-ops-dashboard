# frozen_string_literal: true

class Deployers
  def self.for_today
    if ENV['DEPLOYERS']
      seed = Time.new.strftime('%-d%m%y').to_i
      ENV['DEPLOYERS'].split(',').shuffle(random: Random.new(seed))
    else
      []
    end
  end
end
