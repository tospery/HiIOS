import Combine
import Foundation
import HiIOSNetCombine
import HiIOSNetCore
import Testing

@Test
func combineClientRejectsInvalidURLBeforePublisherStartsNetwork() throws {
    let url = try #require(URL(string: "file:///tmp/private"))
    var failure: NetworkError?
    let subscription = CombineMoyaNetworkClient()
        .send(HTTPRequest(url: url))
        .sink(receiveCompletion: { completion in
            if case let .failure(error) = completion { failure = error }
        }, receiveValue: { _ in })

    #expect(failure == .invalidRequest)
    subscription.cancel()
}
