class WorkflowRun
  def initialize(workflow_run)
    @workflow_run = workflow_run
  end

  def queued?
    workflow_run['status'] == 'queued'
  end

  def in_progress?
    workflow_run['status'] == 'in_progress'
  end

  def succeeded?
    workflow_run['status'] == 'completed' && workflow_run['conclusion'] == 'success'
  end

  def failed?
    workflow_run['status'] == 'completed' && workflow_run['conclusion'] == 'failure'
  end

  def link
    workflow_run['html_url']
  end

  def deployer_name
    'GitHub'
  end

  def commit_sha
    workflow_run['head_sha']
  end

  def diff_against_url(other_sha)
    "https://github.com/DFE-Digital/apply-for-postgraduate-teacher-training/compare/#{commit_sha}...#{other_sha}"
  end

private

  attr_reader :workflow_run
end
