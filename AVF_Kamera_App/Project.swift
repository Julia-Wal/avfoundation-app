//
//  Project.swift
//  demo_iOS-app
//
//  Created by Duc Nguyen on 30.10.26.
//

// describes the informations of a project

import Foundation

enum ProjectType: String, Codable {
    case picture
    case video
}

struct Project: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var type: ProjectType
    var fileName: String
    var createdAt: Date = Date()
}
