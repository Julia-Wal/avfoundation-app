//
//  ProjectStorage.swift
//  demo_iOS-app
//
//  Created by Duc Nguyen on 30.10.26.
//

// Funktionen für Speichern und Aufrufen von Projekten (Projekt Infos)
// Speicher-Logik

import Foundation

struct ProjectStore {
    
    // Speicherordner
    static func getProjectDirectory() throws -> URL {
        
        // Damit Documents Ordner von App suchen
        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        
        // erstelle Ordner mit Pfad Document -> Proejects (falls dieser nicht existiert)
        let projectDirectory = documentsDirectory.appendingPathComponent("Projects") // neuer Ordner im Pfad
        
        try FileManager.default.createDirectory(
            at: projectDirectory,
            withIntermediateDirectories: true
        )
        
        return projectDirectory
    }
    
    
    // Bild speichern
    static func saveMedia(data: Data, fileExtension: String) throws -> String { // imageData und videoData
        
        let fileName = "\(UUID().uuidString).\(fileExtension)" // .jpg oder .mov
        let directory = try getProjectDirectory() // Speicherort
        let fileURL = directory.appendingPathComponent(fileName) // speichern im Pfad
        try data.write(to: fileURL)
        
        return fileName
    }

    static func saveProjects(_ projects: [Project]) throws {

        let directory = try getProjectDirectory() // Speicherort
        let fileURL = directory.appendingPathComponent("projects.json")
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(projects)
        
        try data.write(to: fileURL) // JSON-Datei speichern
    }
    
    // Projektinformationen laden
    static func getProjects() -> [Project] {

        do {
            
            let directory = try getProjectDirectory()
            let fileURL = directory.appendingPathComponent("projects.json") // Pfad zur JSON-Datei erstellen

            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                return []
            }

            let data = try Data(contentsOf: fileURL) // JSON-Datei einlesen

            // JSON zurück in Swift-Objekte umwandeln
            let decoder = JSONDecoder()
            let projects = try decoder.decode([Project].self, from: data)

            return projects

        } catch {
            print("Fehler beim Laden: \(error)")
            return []
        }
    }
    
    // Medien laden
    static func getMedia(fileName: String) throws -> Data {

        let directory = try getProjectDirectory()
        let fileURL = directory.appendingPathComponent(fileName)

        let data = try Data(contentsOf: fileURL)

        return data
    }
}
