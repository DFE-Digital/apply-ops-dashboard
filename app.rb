require 'sinatra'
require 'http'
require 'yaml'
require 'json'
require 'octokit'

class GitHub
  def self.client
    @client ||= Octokit::Client.new
  end
end

class State
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

  def latest_deploy_to_qa
    @latest_deploy_to_qa ||= qa_deployments.find { |s| s[:result] == "succeeded" }
  end

# https://docs.microsoft.com/en-us/rest/api/azure/devops/build/builds/list?view=azure-devops-rest-5.1
  def qa_deployments
    organization = 'dfe-ssp'
    project = 'Become-A-Teacher'

    params = {
      'api-version' => '5.1',
      'definitions' => 49, # releases pipeline ID
      'branchName' => 'refs/heads/master',
    }

    api_response = HTTP
      .basic_auth(user: ENV.fetch("AZURE_USERNAME"), pass: ENV.fetch("AZURE_ACCESS_TOKEN"))
      .get(
      "https://dev.azure.com/#{organization}/#{project}/_apis/build/builds", params: params
    )

    x = JSON.parse(api_response)['value']
    convert(x.sort_by { |b| b["queueTime"] }.reverse)
  end

  def latest_deploy_to(environment)
    return latest_deploy_to_qa if environment == 'qa'

    relevant_builds.find do |build|
      build[:params]["deploy_#{environment}"] == "true"
    end
  end

  def relevant_builds
    convert(raw_builds)
  end

  def convert(builds)
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

private

  def raw_builds
    @raw_builds ||= begin
      organization = 'dfe-ssp'
      project = 'Become-A-Teacher'

      params = {
        'api-version' => '5.1',
        'definitions' => 325, # releases pipeline ID
      }

      api_response = HTTP
        .basic_auth(user: ENV.fetch("AZURE_USERNAME"), pass: ENV.fetch("AZURE_ACCESS_TOKEN"))
        .get(
        "https://dev.azure.com/#{organization}/#{project}/_apis/build/builds", params: params
      )

      JSON.parse(api_response)['value']
    end
  end
end

class MyApp < Sinatra::Base
  get '/' do
    erb :index, locals: { state: State.new }
  end
end
