import Foundation
import WalletConnectKMS
import WalletConnectUtils

class DeletePushSubscriptionService {
    enum Errors: Error {
        case pushSubscriptionNotFound
    }
    private let networkingInteractor: NetworkInteracting
    private let kms: KeyManagementServiceProtocol
    private let logger: ConsoleLogging
    private let pushSubscriptionStore: CodableStore<PushSubscription>

    init(networkingInteractor: NetworkInteracting,
         kms: KeyManagementServiceProtocol,
         logger: ConsoleLogging,
         pushSubscriptionStore: CodableStore<PushSubscription>) {
        self.networkingInteractor = networkingInteractor
        self.kms = kms
        self.logger = logger
        self.pushSubscriptionStore = pushSubscriptionStore
    }

    func delete(topic: String) async throws {
        guard let _ = try? pushSubscriptionStore.get(key: topic)
        else { throw Errors.pushSubscriptionNotFound}
        let protocolMethod = PushDeleteProtocolMethod()
        let reason = PushReasonCode.userDisconnected
        logger.debug("Will delete push subscription for reason: message: \(reason.message) code: \(reason.code)")
        let request = RPCRequest(method: protocolMethod.method, params: reason)
        try await networkingInteractor.request(request, topic: topic, protocolMethod: protocolMethod)
        pushSubscriptionStore.delete(forKey: topic)
        kms.deleteSymmetricKey(for: topic)
        networkingInteractor.unsubscribe(topic: topic)
    }
}
