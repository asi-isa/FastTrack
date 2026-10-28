//
//  TrackView.swift
//  FastTrack
//
//  Created by Ali Soner Inceoglu on 27.10.26.
//

import SwiftUI


struct TrackView: View {
    let track: Track
    let onSelected: (Track) -> Void
    @State private var isHovering = false
    
    var body: some View {
        Button {
            onSelected(track)
        } label: {
            ZStack(alignment: .bottom) {
                AsyncImage(url: track.artworkUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                    case .failure(_):
                        Image(systemName: "questionmark")
                            .symbolVariant(.circle)
                            .font(.largeTitle)
                    default:
                        ProgressView()
                    }
                }
                .frame(width: 150, height: 150)
                .scaleEffect(isHovering ? 1.2 : 1)
                .clipped()
                
                VStack {
                    Text(track.trackName)
                        .lineLimit(1)
                        .font(.headline)
                    
                    Text(track.artistName)
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }
                .padding(5)
                .frame(width: 150)
                .background(.regularMaterial)
            }
        }
        .buttonStyle(.borderless)
        .onHover { hovering in withAnimation { isHovering = hovering } }
        .pointerStyle(isHovering ? .link : .default)
        .border(.primary, width: isHovering ? 3 : 0)
    }
}

#Preview {
    TrackView(track: Track(trackId: 1, artistName: "Nirvana", trackName: "Smells Like Teen Spirit", previewUrl: URL(string: "abc")!, artworkUrl100: "https://bit.ly/teen-spirit")) { track in
        print(track.previewUrl)
    }
}
