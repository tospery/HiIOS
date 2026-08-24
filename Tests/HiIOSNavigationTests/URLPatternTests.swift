import Foundation
import HiIOSNavigation
import Testing

@Test
func urlPatternMatchesOnlyTheExactStructuralComponents() throws {
    let callback = URLPattern(
        scheme: "https",
        host: "example.com",
        path: "/oauth/callback",
        port: nil,
        fragment: nil
    )
    let exact = try #require(
        URL(string: "https://example.com/oauth/callback?code=secret&state=secret")
    )

    #expect(callback.matches(exact))
    #expect(!callback.matches(try #require(URL(string: "http://example.com/oauth/callback"))))
    #expect(!callback.matches(try #require(URL(string: "https://api.example.com/oauth/callback"))))
    #expect(!callback.matches(try #require(URL(string: "https://example.com/OAuth/callback"))))
    #expect(!callback.matches(try #require(URL(string: "https://example.com:443/oauth/callback"))))
    #expect(!callback.matches(try #require(URL(string: "https://example.com/oauth/callback#done"))))

    let documented = URLPattern(
        scheme: "custom",
        host: "callback",
        path: "",
        port: 8443,
        fragment: "finished"
    )
    #expect(documented.matches(
        try #require(URL(string: "custom://callback:8443#finished"))
    ))
}

@Test
func urlPatternRejectsAnEncodedSeparatorThatChangesPathHierarchy() throws {
    let pattern = URLPattern(
        scheme: "https",
        host: "example.com",
        path: "/oauth/callback",
        port: nil,
        fragment: nil
    )
    let encodedSeparator = try #require(
        URL(string: "https://example.com/oauth%2Fcallback")
    )

    #expect(!pattern.matches(encodedSeparator))
}
