
//
//  CombineExtension.swift
//  VIPERCoordinator
//
//  Created by Preet Singh on 3/01/26.
//

import Combine
import Foundation

extension Publisher where Failure == Never {
    /// Bridge a Combine publisher to async/await.
    func firstValue() async -> Output? {
        await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = first()
                .sink { value in
                    continuation.resume(returning: value)
                    cancellable?.cancel()
                }
        }
    }
}

extension Task {
    /// Bridge an async task into a Combine publisher.
    static func publisher(
        priority: TaskPriority? = nil,
        operation: @escaping () async throws -> Success
    ) -> AnyPublisher<Success, Error> where Failure == Error {
        Deferred {
            Future { promise in
                Task<Void, Never>(priority: priority) {
                    do {
                        let result = try await operation()
                        promise(.success(result))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
