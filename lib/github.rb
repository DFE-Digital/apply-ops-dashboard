require 'octokit'

class GitHub
  def self.client
    @client ||= Octokit::Client.new
  end
end
