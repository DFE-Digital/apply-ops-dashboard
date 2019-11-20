class Diff
  def self.pull_requests_between(to_sha, from_sha)
    @compares ||= {}
    @compares[to_sha + from_sha] ||= GitHub.client.compare('DFE-Digital/apply-for-postgraduate-teacher-training', from_sha, to_sha)
    compare = @compares[to_sha + from_sha]

    compare[:commits].select { |commit|
      commit[:commit][:message].start_with?("Merge pull request")
    }.compact.map { |commit|
      [commit.to_h.dig(:commit, :author, :name), commit[:commit][:message].lines.last]
    }
  end
end
