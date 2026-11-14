import Foundation
import HiIOSNavCore
import Testing

private enum Context: Hashable, Sendable { case external, inApp }

private enum Route: Equatable, Sendable {
    case user(String)
    case repository(String, String)
    case issue(String, String, Int, fragment: String?)
    case search(String)
}

private let router = URLRouter<Context, Route>(rules: [
    URLRouteRule(
        URLRouteTemplate(scheme: "app", host: .exact("search"), allowsQuery: true),
        contexts: [.external, .inApp]
    ) { match in
        guard let items = match.url.queryItems, items.count == 1, items[0].name == "q",
              let query = items[0].value, !query.isEmpty else { return nil }
        return .search(query)
    },
    URLRouteRule(URLRouteTemplate(scheme: "app", host: .parameter("login")), contexts: [.external, .inApp]) {
        $0["login"].map(Route.user)
    },
    URLRouteRule(
        URLRouteTemplate(scheme: "app", host: .parameter("owner"), path: "/{repo}"),
        contexts: [.external, .inApp]
    ) { match in
        guard let owner = match["owner"], let repo = match["repo"] else { return nil }
        return .repository(owner, repo)
    },
    URLRouteRule(
        URLRouteTemplate(
            scheme: "https", host: .exact("example.com"), path: "/{owner}/{repo}/issues/{number}",
            allowsFragment: true),
        contexts: [.inApp]
    ) { match in
        guard let owner = match["owner"], let repo = match["repo"],
              let number = match["number"].flatMap(Int.init), number > 0 else { return nil }
        return .issue(owner, repo, number, fragment: match.url.percentEncodedFragment)
    }
])

private func url(_ string: String) throws -> URL { try #require(URL(string: string)) }

@Test
func routerResolvesHostAndPathParametersInOrder() throws {
    #expect(router.route(try url("app://octocat"), context: .external) == .user("octocat"))
    #expect(router.route(try url("app://octocat/hello"), context: .external) == .repository("octocat", "hello"))
    #expect(router.route(try url("app://search?q=swift"), context: .external) == .search("swift"))
    #expect(router.route(try url("APP://octocat/hello%20world"), context: .inApp)
        == .repository("octocat", "hello world"))
}

@Test
func routerRespectsContextsQueryAndFragmentRules() throws {
    let issue = try url("https://example.com/o/r/issues/7#issuecomment-1")
    #expect(router.route(issue, context: .inApp) == .issue("o", "r", 7, fragment: "issuecomment-1"))
    #expect(router.route(issue, context: .external) == nil)
    #expect(router.route(try url("app://octocat?x=1"), context: .inApp) == nil)
    #expect(router.route(try url("app://octocat#top"), context: .inApp) == nil)
    #expect(router.route(try url("app://search?q="), context: .inApp) == nil)
    #expect(router.route(try url("https://EXAMPLE.com/o/r/issues/0"), context: .inApp) == nil)
}

@Test
func sanitizerRejectsUnsafeAuthoritiesAndSegments() throws {
    for unsafe in [
        "app://user@octocat", "app://octocat:", "app://octocat:80", "app://octo%63at",
        "app://octocat/hello/", "app://octocat//hello", "app://octocat/%2e%2e", "app://octocat/a%2Fb",
        "app://octocat/a%252Fb", "app://octocat/a%0Ab", "https://example.com/o/r/issues/7/"
    ] {
        #expect(router.route(try url(unsafe), context: .inApp) == nil, "\(unsafe)")
    }
    let sanitized = try #require(SanitizedURL(try url("https://example.com/a/b?x=1#f")))
    #expect(sanitized.scheme == "https")
    #expect(sanitized.pathSegments == ["a", "b"])
    #expect(sanitized.queryItems == [URLQueryItem(name: "x", value: "1")])
    #expect(sanitized.percentEncodedFragment == "f")
    #expect(try #require(SanitizedURL(try url("app://octocat"))).pathSegments.isEmpty)
}

@Test
func routeStackReportsRemovedRoutesForEveryWrite() {
    var stack = NavigationRouteStack<String>()
    stack.push("a")
    stack.push("b")
    stack.push("c")
    #expect(stack.setRoutes(["a", "x"]) == ["b", "c"])
    stack.push("y")
    #expect(stack.pop() == ["y"])
    stack.push("b")
    stack.push("x")
    #expect(stack.pop(through: "x") == ["x"])
    #expect(stack.routes == ["a", "x", "b"])
    #expect(stack.pop(through: "missing").isEmpty)
    #expect(stack.popToRoot() == ["a", "x", "b"])
    #expect(stack.isEmpty)
    #expect(stack.pop(count: 3).isEmpty)
}
