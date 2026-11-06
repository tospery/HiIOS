import Foundation
import HiIOSNetCore
import HiIOSNetRxSwift
import Testing

@Test
func rxClientRejectsInvalidURLBeforeSubscriptionStartsNetwork() throws {
    let url = try #require(URL(string: "file:///tmp/private"))
    var failure: NetworkError?
    let disposable = RxMoyaNetworkClient()
        .send(HTTPRequest(url: url))
        .subscribe(onFailure: { failure = $0 as? NetworkError })

    #expect(failure == .invalidRequest)
    disposable.dispose()
}
