//
//  ErrorModal.swift
//  assignment
//
//  Created by Jayant Dhingra on 29/07/25.
//

import Foundation

struct ErrorModel: Identifiable, Error {
    let id = UUID()
    let title: String
    let message: String
    let closable: Bool
}

enum ConfigurationErrors {
    static let configFileMissing = ErrorModel(
        title: "Config file not found",
        message: "Could not load Config.plist.",
        closable: true
    )
    static let configError = ErrorModel(
        title: "Configuration Error",
        message: "Invalid Capella URL or credentials.",
        closable: true
    )
}
