import Foundation
@testable import WalletConnectUtils

class SIWEMessageFormatterMock: SIWEFromCacaoFormatting {
    func formatMessage(from payload: WalletConnectUtils.CacaoPayload, includeRecapInTheStatement: Bool) throws -> String {
        fatalError()
    }

    
    var formattedMessage: String!

    func formatMessages(from payload: CacaoPayload) throws -> String {
        return formattedMessage
    }
}
