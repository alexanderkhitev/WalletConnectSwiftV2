import Foundation

protocol SocketAuthenticating {
    func createAuthToken() throws -> String
}

struct SocketAuthenticator: SocketAuthenticating {
    private let clientIdStorage: ClientIdStoring
    private let relayHost: String

    init(clientIdStorage: ClientIdStoring, relayHost: String) {
        self.clientIdStorage = clientIdStorage
        self.relayHost = relayHost
    }

    func createAuthToken() throws -> String {
        let keyPair = try clientIdStorage.getOrCreateKeyPair()
        return try JWTFactory(keyPair: keyPair).createRelayJWT(
            sub: getSubject(),
            aud: getAudience()
        )
    }

    private func getAudience() -> String {
        return "wss://\(relayHost)"
    }

    private func getSubject() -> String {
        return Data.randomBytes(count: 32).toHexString()
    }
}
