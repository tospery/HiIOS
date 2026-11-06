import HiIOSGHTrending
import Testing

private let repositoryFixture = """
    <html><main>
      <article class="Box-row">
        <h2><a href="/example-lab/toolkit">example-lab / toolkit</a></h2>
        <p>Swift &amp; Unicode 工具</p>
        <span itemprop="programmingLanguage">Swift</span>
        <a href="/example-lab/toolkit/stargazers">12</a>
        <a href="/example-lab/toolkit/forks">3</a>
        <span class="float-sm-right">4 stars today</span>
      </article>
      <article class="Box-row">
        <h2><a href="/sample-org/second">sample-org / second</a></h2>
      </article>
    </main></html>
    """

private let developerFixture = """
    <html><main>
      <article class="Box-row">
        <h1><a href="/sampledev">示例开发者</a></h1>
        <h2><a href="/sampledev/toolkit">toolkit</a></h2>
        <p>Builds useful tools.</p>
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
    #expect(items[0].stars == "12")
    #expect(items[0].forks == "3")
    #expect(items[1].rank == 2)
}

@Test
func developerParserReadsIdentityAndPopularRepository() throws {
    let items = try GitHubTrendingHTMLParser().developers(from: developerFixture)
    #expect(items.count == 1)
    #expect(items[0].login == "sampledev")
    #expect(items[0].displayName == "示例开发者")
    #expect(items[0].popularRepository == "sampledev/toolkit")
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
