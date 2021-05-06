require 'octokit'
require_relative 'github'

class Deployment
  def initialize(deployment)
    @deployment = deployment
  end

  def url
    deployment['url']
  end

  def environment
    deployment['environment']
  end

  def status
    return statuses[0]['state'] unless statuses[0]['state'] == 'inactive'

    statuses[1]['state']
  end

  def deployer_name
    user['name'] || user['login']
  end

  def branch_name
    deployment['ref']
  end

  def link
    GitHub.build_workflow_runs.first.link
  end

  def commit_sha
    deployment['sha']
  end

  def succeeded?
    status == 'success'
  end

  def in_progress?
    status == 'in_progress'
  end

  def queued?
    status == 'queued' || status == 'pending' || status == 'waiting'
  end

  def failed?
    status == 'failure'
  end

  def inactive?
    status == 'inactive'
  end

  def start_time
    deployment['created_at'].strftime('%m/%d/%Y %I:%M%p')
  end

  def diff_against_url(other_sha)
    "https://github.com/DFE-Digital/apply-for-postgraduate-teacher-training/compare/#{commit_sha}...#{other_sha}"
  end

private

  attr_reader :deployment

  def statuses
    @statuses ||= GitHub.client.get deployment['statuses_url']
  end

  def user
    @user ||= GitHub.client.get deployment['creator']['url']
  end
end
