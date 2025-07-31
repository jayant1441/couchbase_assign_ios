//
//  NetworkMonitor.swift
//  assignment
//
//  Created by Jayant Dhingra on 29/07/25.
//

import Foundation
import Network
import Combine

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")
    @Published var isConnected = true
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async { self?.isConnected = (path.status == .satisfied) }
        }
        monitor.start(queue: queue)
    }
}

