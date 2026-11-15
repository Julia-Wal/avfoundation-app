//
//  ProjectView.swift
//  demo_iOS-app
//
//  Created by Duc Nguyen on 30.10.26.
//

// User interface


import SwiftUI
import PhotosUI
import AVFoundation

// Struct speichert nur Infos für Darstellung
struct MediaThumbnail: Identifiable {
    var id: UUID { project.id }
    let image: UIImage
    let project: Project // Thumbnail nur wenn Video obv
}

struct ProjectView: View {

    @State private var selectedFilter = "All"
    @State private var searchText = ""
    @State private var newestFirst = true // newest first standard
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var mediaThumbnails: [MediaThumbnail] = [] // Alle Pics sammeln

    var body: some View {
        
        VStack(spacing: 16) {
            
            // Titel
            HStack {
                Text("Projects")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Sort button
                Button {
                    newestFirst.toggle()
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.title3)
                }
            }
            .padding(.horizontal)
            
            // Suchleiste
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.gray)
                
                TextField("Search projects...", text: $searchText)
            }
            .padding(10)
            .background(.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
            
            // Filter
            HStack {
                filterButton("All")
                filterButton("Pictures")
                filterButton("Videos")
                Spacer()
            }
            
            //.padding(.leading, 16)
            .padding(.horizontal)
            
            // Anzeige des ausgewählten Bildes oder Platzhalter
            if !mediaThumbnails.isEmpty {
                
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 100))],
                        spacing: 10
                    ) {
                        ForEach(mediaThumbnails) { media in
                            VStack(alignment: .leading, spacing: 4) {
                                
                                ZStack {
                                    Image(uiImage: media.image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                        .cornerRadius(12)
                                    
                                    // Play-Symbol bei Videos
                                    if media.project.type == .video {
                                        Image(systemName: "play.circle.fill")
                                            .font(.system(size: 30))
                                            .foregroundStyle(.white)
                                            .shadow(radius: 4)
                                    }
                                }
                                
                                // Dateiname
                                Text(media.project.name)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                                
                                // Erstellungsdatum
                                Text(media.project.createdAt, style: .date)
                                    .font(.caption2)
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                }
                
            } else {
                
                ContentUnavailableView(
                    "No Projects",
                    systemImage: "photo.on.rectangle.angled",
                    description: Text("Your saved projects will appear here.")
                )
            }
            
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 20,
                matching: .any(of: [.images, .videos])
            ) {
                Label("Import Media", systemImage: "plus")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.purple.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .padding(.top)
        
        .onChange(of: selectedItems) {oldValue, newValue in
            Task {
                mediaThumbnails = []
                
                for item in newValue {
                    
                    // Prüfen, ob es ein Bild ist
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        
                        // Bild vorerst temporär speichern
                        let url = FileManager.default.temporaryDirectory
                            .appendingPathComponent(UUID().uuidString + ".jpg")
                        
                        try? data.write(to: url)
                        
                        let project = Project(
                            name: "Bild",
                            type: .picture,
                            fileName: url.lastPathComponent
                        )
                        
                        addProject(project, url: url)
                        
                        continue
                    }
                    
                    // Falls kein Bild: Video laden
                    if let movie = try? await item.loadTransferable(type: VideoFile.self) {
                        
                        let project = Project(
                            name: "Video",
                            type: .video,
                            fileName: movie.url.lastPathComponent
                        )
                        
                        addProject(project, url: movie.url)
                    }
                }
            }
        }
    }
    
    struct VideoFile: Transferable {
        let url: URL

        static var transferRepresentation: some TransferRepresentation {
            FileRepresentation(importedContentType: .movie) { receivedFile in

                let fileName = UUID().uuidString + ".mov"
                let destination = FileManager.default.temporaryDirectory
                    .appendingPathComponent(fileName)

                try FileManager.default.copyItem(
                    at: receivedFile.file,
                    to: destination
                )

                return VideoFile(url: destination)
            }
        }
    }
    
    func addProject(_ project: Project, url: URL) {
        var thumbnail: UIImage?

        if project.type == .picture { // Bei Bild: Bild direkt laden
            thumbnail = UIImage(contentsOfFile: url.path)
        } else if project.type == .video { // Thumbnail aus Video generieren
            thumbnail = generateThumbnail(url: url)
        }

        if let thumbnail = thumbnail {
            mediaThumbnails.append(
                MediaThumbnail(
                    image: thumbnail,
                    project: project
                )
            )
        }
    }
    
    
    func generateThumbnail(url: URL) -> UIImage? {

        let asset = AVURLAsset(url: url)
        let imgGenerator = AVAssetImageGenerator(asset: asset)

        imgGenerator.appliesPreferredTrackTransform = true

        guard let cgImage = try? imgGenerator.copyCGImage(
            at: CMTimeMake(value: 0, timescale: 1),
            actualTime: nil
        ) else {
            print("*** Error generating thumbnail")
            return nil
        }

        let thumbnail = UIImage(cgImage: cgImage)
        return thumbnail
    }


    // Funktion für die Filter-Buttons
    func filterButton(_ title: String) -> some View {

        Button {
            selectedFilter = title
        } label: {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    selectedFilter == title
                    ? Color.purple.opacity(0.2)
                    : Color.gray.opacity(0.1)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProjectView()
}
    
