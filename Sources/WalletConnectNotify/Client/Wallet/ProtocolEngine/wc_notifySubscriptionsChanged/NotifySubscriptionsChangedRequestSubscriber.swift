import Foundation
import Combine

class NotifySubscriptionsChangedRequestSubscriber {

    private let networkingInteractor: NetworkInteracting
    private let kms: KeyManagementServiceProtocol
    private var publishers = [AnyCancellable]()
    private let logger: ConsoleLogging
    private let notifyStorage: NotifyStorage
    private let notifySubscriptionsBuilder: NotifySubscriptionsBuilder

    init(networkingInteractor: NetworkInteracting,
         kms: KeyManagementServiceProtocol,
         logger: ConsoleLogging,
         notifyStorage: NotifyStorage,
         notifySubscriptionsBuilder: NotifySubscriptionsBuilder
    ) {
        self.networkingInteractor = networkingInteractor
        self.kms = kms
        self.logger = logger
        self.notifyStorage = notifyStorage
        self.notifySubscriptionsBuilder = notifySubscriptionsBuilder
        subscribeForNofifyChangedRequests()
    }


    private func subscribeForNofifyChangedRequests() {
        let protocolMethod =  NotifySubscriptionsChangedRequest()

        networkingInteractor.requestSubscription(on: protocolMethod).sink { [unowned self]  (payload: RequestSubscriptionPayload<NotifySubscriptionsChangedRequestPayload.Wrapper>) in


            Task(priority: .high) {
                logger.debug("Received Subscriptions Changed Request")

                guard
                    let (responsePayload, _) = try? NotifySubscriptionsChangedRequestPayload.decodeAndVerify(from: payload.request)
                else { fatalError() /* TODO: Handle error */ }

                // todo varify signature with notify server diddoc authentication key

                let subscriptions = try await notifySubscriptionsBuilder.buildSubscriptions(responsePayload.subscriptions)

                notifyStorage.replaceAllSubscriptions(subscriptions)

                var logProperties = [String: String]()
                for (index, subscription) in subscriptions.enumerated() {
                    let key = "subscription_\(index + 1)"
                    logProperties[key] = subscription.topic
                }

                logger.debug("Updated Subscriptions by Subscriptions Changed Request", properties: logProperties)

            }

        }.store(in: &publishers)
    }

}
