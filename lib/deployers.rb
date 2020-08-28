class Deployers
  def self.for_today
    if ENV['DEPLOYERS']
      seed = Time.new.strftime('%-d%m%y').to_i
      all_deployers = JSON.parse(ENV['DEPLOYERS'])
      yesterdays_deployer_file = ENV['YESTERDAYS_DEPLOYER_FILE']
      all_deployers.delete(JSON.parse(File.read(yesterdays_deployer_file))) if File.exist?(yesterdays_deployer_file)
      all_deployers.shuffle(random: Random.new(seed))
    else
      []
    end
  end
end
