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

struct MediaThumbnail: Identifiable {
    let id = UUID()
    let image: UIImage
    let isVideo: Bool // Thumbnail nur wenn Video obv
    
    let fileName: String
    let creationTime: Date
}

struct ProjectView: View {

    @State private var selectedFilter = "All"
    @State private var searchText = ""
    @State private var newestFirst = true // newest first standard
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var mediaThumbnails: [MediaThumbnail] = []

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

                                    ZStack {

                                        Image(uiImage: media.image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipped()
                                            .cornerRadius(12)

                                        // Play-Symbol bei Videos
                                        if media.isVideo {
                                            Image(systemName: "play.circle.fill")
                                                .font(.system(size: 30))
                                                .foregroundStyle(.white)
                                                .shadow(radius: 4)
                                        }
                                    }
                                    // Dateiname
                                    Text(media.filename)
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                                    .lineLimit(1)

                                                // Erstellungsdatum
                                    Text(media.creationDate.formatted(
                                                date: .numeric,
                                                time: .shortened
                                            ))
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
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
                    if let image = try? await item.loadTransferable(type: Image.self) {
                        
                        // SwiftUI Image in UIImage umwandeln können wir
                        // nicht direkt. Deshalb laden wir die Bilddaten:
                    }
                    
                    // Bilddaten laden
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        
                        mediaThumbnails.append(
                            MediaThumbnail(image: image,
                                           isVideo: false,
                                           fileName: fileURL.lastPathComponent,
                                           creationDate: Date())
                        )
                        
                        continue
                    }
                    
                    // Falls kein Bild geladen werden konnte,
                    // versuchen wir ein Video zu laden.
                    if let movie = try? await item.loadTransferable(type: VideoFile.self) {
                        
                        if let thumbnail = generateThumbnail(url: movie.url) {
                            
                            mediaThumbnails.append(
                                MediaThumbnail(image: thumbnail,
                                               isVideo: true,
                                               fileName: fileURL.lastPathComponent,
                                               creationDate: Date())
                            )
                        }
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
    
    func generateThumbnail(url: URL) -> UIImage? {

        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)

        generator.appliesPreferredTrackTransform = true

        let time = CMTime(seconds: 1, preferredTimescale: 600)

        guard let cgImage = try? generator.copyCGImage(
            at: time,
            actualTime: nil
        ) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    // Funktion für die Filter-Buttons
    private func filterButton(_ title: String) -> some View {

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
