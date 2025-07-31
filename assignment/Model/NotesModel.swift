//
//  NotesModel.swift
//  assignment
//
//  Created by Jayant Dhingra on 29/07/25.
//

import Foundation

struct Note: Identifiable, Codable {
    let id: Int
    var title: String
    var content: String
    var createdAt: Date
}
