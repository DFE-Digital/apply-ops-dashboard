require 'yaml'
require 'active_support/all'

require_relative 'azure'
require_relative 'github'
require_relative 'build'
require_relative 'diff'
require_relative 'deployers'

class State
  def master_broken?
    latest_master_build.failed? || latest_deployment_to('qa').failed?
  end

  def deploy_to_production_failed?
    latest_deployment_to('production').failed?
  end
  
  def deploying_to_qa?
    latest_master_build.in_progress? || latest_master_build.queued? || latest_deployment_to('qa').in_progress?
  end

  def deploying_to_staging?
    latest_deployment_to('staging').in_progress?
  end

  def deploying_to_sandbox?
    latest_deployment_to('sandbox').in_progress?
  end

  def deploying_to_production?
    latest_deployment_to('production').in_progress?
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
  
private

  def latest_master_build
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
    else
      nil
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
    else
      nil
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
