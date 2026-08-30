import HiIOSGitHubTrending
import Testing

struct GitHubTrendingTests {
    @Test func repositoryParserExtractsRankedRepository() throws {
        let html = #"<article><h2><a href="/openai/codex">openai / codex</a></h2><p>Agent coding.</p><span itemprop="programmingLanguage">Swift</span><a href="/openai/codex/stargazers">12.3k</a></article>"#
        let item = try GitHubTrendingHTMLParser().repositories(from: html).only
        #expect(item.owner == "openai")
        #expect(item.name == "codex")
        #expect(item.programmingLanguage == "Swift")
    }

    @Test func malformedPageDoesNotBecomeAnEmptyRanking() {
        #expect(throws: GitHubTrendingError.schemaMismatch) {
            try GitHubTrendingHTMLParser().repositories(from: "<html>changed</html>")
        }
    }
}

private extension Array { var only: Element { self[0] } }
