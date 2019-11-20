require 'http'
require 'yaml'
require 'json'
require 'octokit'

class State
  def master_broken?
    qa_builds.first.failed?
  end

  def deploy_to_production_failed?
    latest_deploy_to('production').failed?
  end

  def deploying_to_staging?
    latest_deploy_to('staging').in_progress?
  end

  def deploying_to_production?
    latest_deploy_to('production').in_progress?
  end

  def staging_and_production_not_in_sync?
    latest_deploy_to('staging').commit_sha != latest_deploy_to('production').commit_sha
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
      build.params["deploy_#{environment}"] == "true"
    end
  end

  def latest_successfull_deploy_to(environment)
    return latest_successfull_deploy_to_qa if environment == 'qa'

    release_builds.find do |build|
      build.succeeded? && build.params["deploy_#{environment}"] == "true"
    end
  end

private

  def latest_successfull_deploy_to_qa
    @latest_successfull_deploy_to_qa ||= qa_builds.find(&:succeeded?)
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

    # https://docs.microsoft.com/en-us/rest/api/azure/devops/build/builds/list?view=azure-devops-rest-5.1
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
      builds.map { |azure_build| Build.new(azure_build) }
    end
  end

  class Build
    def initialize(azure_build)
      @azure_build = azure_build
    end

    def start_time
      DateTime.parse(azure_build['queueTime']).strftime('%m/%d/%Y %I:%M%p')
    end

    def succeeded?
      result == "succeeded"
    end

    def failed?
      result == "failed"
    end

    def in_progress?
      result.nil?
    end

    def deployer_name
      name = azure_build['requestedBy']['displayName']
      name == 'Microsoft.VisualStudio.Services.TFS' ? 'Autodeploy' : name
    end

    def params
      azure_build['parameters'] ? JSON.parse(azure_build['parameters']) : nil
    end

    def link
      azure_build['_links']['web']['href']
    end

    def commit_sha
      azure_build['sourceVersion']
    end

  private
    attr_reader :azure_build

    # https://docs.microsoft.com/en-us/rest/api/azure/devops/build/builds/list?view=azure-devops-rest-5.1#buildresult
    def result
      azure_build['result']
    end
  end

  class GitHub
    def self.client
      @client ||= Octokit::Client.new
    end
  end
end
