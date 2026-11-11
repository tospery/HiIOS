import Foundation
import HiIOSGHTrending
import Testing

private let repositoryFixture = """
    <html><main>
      <article class="Box-row">
        <h2><a href="/example-lab/toolkit"><span>example-lab /</span> toolkit</a></h2>
        <p>Swift &amp; Unicode 工具</p>
        <div>
          <span><span class="repo-language-color" style="background-color: #f05138"></span>
            <span itemprop="programmingLanguage">Swift</span></span>
          <a href="/example-lab/toolkit/stargazers">23.8k</a>
          <a href="/example-lab/toolkit/forks">1,203</a>
          <span>Built by
            <a href="/sampledev"><img class="avatar" src="https://avatars.githubusercontent.com/u/1?s=40&amp;v=4"></a>
            <a href="/otherdev"><img class="avatar" src="https://evil.test/a.png"></a>
            <a href="/sampledev"><img class="avatar" src="https://avatars.githubusercontent.com/u/1?s=40&amp;v=4"></a>
          </span>
          <span class="float-sm-right">3,108 stars today</span>
        </div>
      </article>
      <article class="Box-row">
        <h2><a href="/sample-org/second">sample-org / second</a></h2>
      </article>
    </main></html>
    """

private let developerFixture = """
    <html><main>
      <article class="Box-row d-flex">
        <a href="/sampledev"><img class="avatar-user" src="https://avatars.githubusercontent.com/u/1?s=96&amp;v=4"></a>
        <h1 class="h3"><a href="/sampledev">示例开发者</a></h1>
        <article>
          <h1 class="h4"><a href="/sampledev/toolkit">toolkit</a></h1>
          <div class="f6 color-fg-muted mt-1">Builds useful tools.</div>
        </article>
      </article>
      <article class="Box-row d-flex">
        <h1 class="h3"><a href="/orgmember">Org Member</a></h1>
        <p><svg class="octicon octicon-organization"><title>Works for Example Co.</title></svg>
          <span class="Truncate-text">Example Co.</span></p>
      </article>
    </main></html>
    """

@Test
func repositoryParserReadsDOMRanksAndDecodedText() throws {
    let items = try GitHubTrendingHTMLParser().repositories(from: repositoryFixture)
    #expect(items.count == 2)
    #expect(items[0].rank == 1)
    #expect(items[0].id == "example-lab/toolkit")
    #expect(items[0].summary == "Swift & Unicode 工具")
    #expect(items[0].programmingLanguage == "Swift")
    #expect(items[0].programmingLanguageColor == "#F05138")
    #expect(items[0].stars == 23_800)
    #expect(items[0].forks == 1_203)
    #expect(items[0].starsInPeriod == 3_108)
    #expect(items[0].builtBy.map(\.login) == ["sampledev", "otherdev"])
    #expect(items[0].builtBy[0].avatarURL?.host == "avatars.githubusercontent.com")
    // 非 GitHub 图片域的头像不进入模型。
    #expect(items[0].builtBy[1].avatarURL == nil)
    #expect(items[1].rank == 2)
    #expect(items[1].stars == nil)
    #expect(items[1].builtBy.isEmpty)
}

@Test
func developerParserReadsIdentityAvatarAndPopularRepository() throws {
    let items = try GitHubTrendingHTMLParser().developers(from: developerFixture)
    #expect(items.count == 2)
    #expect(items[0].login == "sampledev")
    #expect(items[0].displayName == "示例开发者")
    #expect(items[0].avatarURL?.host == "avatars.githubusercontent.com")
    #expect(items[0].popularRepository == "sampledev/toolkit")
    #expect(items[0].popularRepositorySummary == "Builds useful tools.")
    #expect(items[1].popularRepository == nil)
    #expect(items[1].popularRepositorySummary == nil)
    #expect(items[1].company == "Example Co.")
}

/// 低频手工检查：把保存到本机的真实页面交给解析器，不访问网络。
/// `HIIOS_GH_TRENDING_HTML_DIR` 指向含 `repos.html`、`devs.html` 的目录时才运行。
@Test(.enabled(if: ProcessInfo.processInfo.environment["HIIOS_GH_TRENDING_HTML_DIR"] != nil))
func parserReadsLocallySavedLivePages() throws {
    let directory = URL(fileURLWithPath: ProcessInfo.processInfo.environment["HIIOS_GH_TRENDING_HTML_DIR"] ?? "")
    let repositories = try GitHubTrendingHTMLParser().repositories(
        from: String(contentsOf: directory.appendingPathComponent("repos.html"), encoding: .utf8))
    #expect(repositories.count >= 5)
    #expect(repositories.contains { $0.stars != nil && $0.forks != nil && $0.starsInPeriod != nil })
    #expect(repositories.contains { !$0.builtBy.isEmpty && $0.builtBy.allSatisfy { $0.avatarURL != nil } })
    #expect(repositories.contains { $0.programmingLanguageColor != nil })
    let developers = try GitHubTrendingHTMLParser().developers(
        from: String(contentsOf: directory.appendingPathComponent("devs.html"), encoding: .utf8))
    #expect(developers.count >= 5)
    #expect(developers.allSatisfy { $0.avatarURL != nil })
    #expect(developers.contains { $0.popularRepository != nil && $0.popularRepositorySummary != nil })
}

@Test
func parserDistinguishesExplicitEmptyStateFromChangedOrPartialDOM() throws {
    let empty = "<html><main><div class='blankslate'>No entries</div></main></html>"
    #expect(try GitHubTrendingHTMLParser().repositories(from: empty).isEmpty)
    #expect(try GitHubTrendingHTMLParser().developers(from: empty).isEmpty)
    #expect(throws: GitHubTrendingError.schemaMismatch) {
        try GitHubTrendingHTMLParser().repositories(from: "<html><main></main></html>")
    }
    #expect(throws: GitHubTrendingError.schemaMismatch) {
        try GitHubTrendingHTMLParser().repositories(
            from: "<main><article class='Box-row'><h2>Missing link</h2></article></main>")
    }
    #expect(throws: GitHubTrendingError.schemaMismatch) {
        try GitHubTrendingHTMLParser().developers(
            from: "<main><article class='Box-row'><h1><a href='//evil.test/u'>u</a></h1></article></main>")
    }
}
