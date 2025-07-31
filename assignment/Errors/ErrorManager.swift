//
//  ErrorManager.swift
//  assignment
//
//  Created by Jayant Dhingra on 29/07/25.
//

import Foundation

// ErrorManager.swift
import SwiftUI
import Combine

class ErrorManager: ObservableObject {
    static let shared = ErrorManager()
    @Published var errors: [ErrorModel] = []
    private init() {}
    func showError(error: ErrorModel) {
        DispatchQueue.main.async { self.errors.append(error) }
    }
    func dismissNext() {
        DispatchQueue.main.async { if !self.errors.isEmpty { self.errors.removeFirst() } }
    }
}
