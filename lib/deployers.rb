class Deployers
  def self.for_today
    if ENV['DEPLOYERS']
      seed = Time.new.strftime('%-d%m%y').to_i
      all_deployers = JSON.parse(ENV['DEPLOYERS'])
      all_deployers.delete(JSON.parse(File.read('yesterdays_deployer.json'))) if File.exist?('yesterdays_deployer.json')
      all_deployers.shuffle(random: Random.new(seed))
    else
      []
    end
  end
end
