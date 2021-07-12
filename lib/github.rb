require 'octokit'
require_relative 'deployment'
require_relative 'workflow_run'

class GitHub
  GITHUB_REPO = 'DFE-Digital/apply-for-postgraduate-teacher-training'.freeze
  DEPLOY_WORKFLOW = 'deploy.yml'.freeze
  BUILD_WORKFLOW = 'build.yml'.freeze
  HOTFIX_BRANCH = 'hotfix'.freeze

  def self.client
    @client ||= Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
  end

  def self.build_workflow_runs
    options = { branch: 'main', per_page: 5, page: 1 }
    runs = client.workflow_runs(GITHUB_REPO, BUILD_WORKFLOW, options)
    return nil if runs&.total_count&.zero?

    runs.workflow_runs.map { |workflow_run| WorkflowRun.new(workflow_run) }
  end

  def self.deployment_workflow_runs
    options = { branch: 'main', per_page: 5, page: 1 }
    runs = client.workflow_runs(GITHUB_REPO, DEPLOY_WORKFLOW, options)
    return nil if runs&.total_count&.zero?

    runs.workflow_runs.map { |workflow_run| WorkflowRun.new(workflow_run) }
  end

  def self.deployments(environment)
    options = { environment: environment, per_page: 10, page: 1, task: 'deploy' }
    deployments = client.deployments(GITHUB_REPO, options)
    return nil if deployments&.length&.zero?

    deployments.map { |deployment| Deployment.new(deployment) }
  end

  def self.trigger_deploy_workflow_run(github_client, commit_sha, environment)
    inputs = { sha: commit_sha }
    inputs[environment] = 'true'
    options = { inputs: inputs }

    github_client.workflow_dispatch(GITHUB_REPO, DEPLOY_WORKFLOW, 'refs/heads/main', options)
  end
end
