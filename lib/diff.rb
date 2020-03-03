# frozen_string_literal: true

class Diff
  def self.pull_requests_between(to_sha, from_sha)
    compare = GitHub.client.compare(GitHub::GITHUB_REPO, from_sha, to_sha)

    merge_commits = compare[:commits].select do |commit|
      commit[:commit][:message].start_with?('Merge pull request')
    end

    merge_commits.compact.map do |commit|
      [commit.to_h.dig(:commit, :author, :name), commit[:commit][:message].lines.last]
    end
  end
end
