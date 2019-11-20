require 'http'
require 'yaml'
require 'json'
require 'octokit'

class State
  def master_broken?
    qa_builds.first[:result] != "succeeded"
  end

  def unreleased_pull_requests_since(commit_sha)
    @compares ||= {}
    @compares[commit_sha] ||= GitHub.client.compare('DFE-Digital/apply-for-postgraduate-teacher-training', commit_sha, "master")
    compare = @compares[commit_sha]

    compare[:commits].select { |commit|
      commit[:commit][:message].start_with?("Merge pull request")
    }.compact.map { |commit|
      [commit.to_h.dig(:commit, :author, :name), commit[:commit][:message].lines.last]
    }
  end

  def latest_deploy_to(environment)
    return latest_successfull_deploy_to_qa if environment == 'qa'

    release_builds.find do |build|
      build[:params]["deploy_#{environment}"] == "true"
    end
  end

private

  def latest_successfull_deploy_to_qa
    @latest_successfull_deploy_to_qa ||= qa_builds.find { |s| s[:result] == "succeeded" }
  end

  def qa_builds
    @qa_builds ||= begin
      params = {
        'api-version' => '5.1',
        'definitions' => 49, # CI pipeline ID
        'branchName' => 'refs/heads/master',
      }

      Azure.get("/build/builds", params)
    end
  end

  def release_builds
    @raw_builds ||= begin
      params = {
        'api-version' => '5.1',
        'definitions' => 325, # release pipeline ID
      }

      Azure.get("/build/builds", params)
    end
  end

  class Azure
    ORGANISATION = 'dfe-ssp'
    PROJECT = 'Become-A-Teacher'

    def self.get(path, params)
      api_response = HTTP
        .basic_auth(user: ENV.fetch("AZURE_USERNAME"), pass: ENV.fetch("AZURE_ACCESS_TOKEN"))
        .get(
        "https://dev.azure.com/#{ORGANISATION}/#{PROJECT}/_apis#{path}", params: params
      )

      builds = JSON.parse(api_response)['value'].sort_by { |b| b["queueTime"] }.reverse
      convert(builds)
    end

    def self.convert(builds)
      builds.map do |b|
        {
          start: DateTime.parse(b['queueTime']),
          result: b['result'],
          deployer: b['requestedBy']['displayName'],
          params: b['parameters'] ? JSON.parse(b['parameters']) : nil,
          link: b['_links']['web']['href'],
          commit: b['sourceVersion'],
        }
      end
    end
  end

  class GitHub
    def self.client
      @client ||= Octokit::Client.new
    end
  end
end
