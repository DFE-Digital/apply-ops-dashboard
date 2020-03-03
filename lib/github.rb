# frozen_string_literal: true

require 'octokit'

class GitHub
  GITHUB_REPO = 'DFE-Digital/apply-for-postgraduate-teacher-training'.freeze
  HOTFIX_BRANCH = 'hotfix'.freeze

  def self.client
    @client ||= Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
  end
end
