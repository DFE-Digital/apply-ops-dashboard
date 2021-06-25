require 'yaml'
require 'active_support/all'

require_relative 'azure'
require_relative 'github'
require_relative 'build'
require_relative 'diff'
require_relative 'deployers'

class State
  def main_broken?
    latest_main_build.failed? || latest_deployment_to('qa').failed?
  end

  def deploy_to_production_failed?
    latest_deployment_to('production').failed?
  end

  def deploying_to_qa?
    latest_main_build.in_progress? || latest_main_build.queued? || latest_deployment_to('qa').in_progress? || latest_deployment_to('qa').queued?
  end

  def deploying_to_staging?
    latest_deployment_to('staging').in_progress? || latest_deployment_to('staging').queued?
  end

  def deploying_to_sandbox?
    latest_deployment_to('sandbox').in_progress? || latest_deployment_to('sandbox').queued?
  end

  def deploying_to_production?
    latest_deployment_to('production').in_progress? || latest_deployment_to('production').queued?
  end

  def staging_and_production_not_in_sync?
    latest_successfull_deployment_to('staging').commit_sha != latest_successfull_deployment_to('production').commit_sha
  end

  def sandbox_and_production_not_in_sync?
    latest_successfull_deployment_to('sandbox').commit_sha != latest_successfull_deployment_to('production').commit_sha
  end

  def latest_build_to(environment)
    latest_deployment_to(environment)
  end

  def latest_successfull_build_to(environment)
    latest_successfull_deployment_to(environment)
  end

  def deployers_for_today
    Deployers.for_today
  end

  def todays_deployer
    Deployers.for_today[0]['displayName']
  end

  def todays_reserves
    Deployers.for_today.slice(1..2).map { |d| d['displayName'] }.join(', ')
  end

  def hotfix_in_progress?
    GitHub.client.branch(GitHub::GITHUB_REPO, GitHub::HOTFIX_BRANCH).present?
  rescue Octokit::NotFound
    false
  end

  def current_commit_sha_in(environment)
    env_suffix = environment == 'production' ? 'prod' : environment
    HTTP.get("https://apply-#{env_suffix}.london.cloudapps.digital/check").body.to_s.strip
  end

private

  def latest_main_build
    GitHub.build_workflow_runs.first
  end

  def latest_successfull_deployment_to(environment)
    case environment
    when 'qa'
      @latest_successfull_release_to_qa ||= qa_deployments.find(&:succeeded?)
    when 'staging'
      @latest_successfull_release_to_staging ||= staging_deployments.find(&:succeeded?)
    when 'sandbox'
      @latest_successfull_release_to_sandbox ||= sandbox_deployments.find(&:succeeded?)
    when 'production'
      @latest_successfull_release_to_production ||= production_deployments.find(&:succeeded?)
    end
  end

  def latest_deployment_to(environment)
    case environment
    when 'qa'
      qa_deployments.first
    when 'staging'
      staging_deployments.first
    when 'sandbox'
      sandbox_deployments.first
    when 'production'
      production_deployments.first
    end
  end

  def qa_deployments
    @qa_deployments ||= GitHub.deployments('qa')
  end

  def staging_deployments
    @staging_deployments ||= GitHub.deployments('staging')
  end

  def sandbox_deployments
    @sandbox_deployments ||= GitHub.deployments('sandbox')
  end

  def production_deployments
    @production_deployments ||= GitHub.deployments('production')
  end
end
