import SwiftUI
import AVKit

struct ContentView: View {
    @AppStorage("searchText") var searchText: String = ""
    @AppStorage("searchHistory") private var searchHistoryData = Data()
    private var searchHistory: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: searchHistoryData)) ?? []
        }
        nonmutating set {
            searchHistoryData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    @State private var selectedSearchTerm: String?
    @State private var tracks = [Track]()
    @State private var audioPlayer: AVPlayer?
    @State private var searchState = SearchState.none
    
    let gridItems: [GridItem] = [
        GridItem(.adaptive(minimum: 150, maximum: 200))
    ]
    
    var body: some View {
        NavigationSplitView {
            List(
                searchHistory,
                id: \.self,
                selection: $selectedSearchTerm
            ) { item in
                Text(item)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            removeFromSearchHistory(item)
                        }
                    }
            }
            .onChange(of: selectedSearchTerm, { oldValue, newValue in
                guard let term = newValue else { return }
                searchText = term
                startSearch()
            })
            .onDeleteCommand {
                guard let term = selectedSearchTerm else { return }
                
                removeFromSearchHistory(term)
                
                selectedSearchTerm = nil
            }
        } detail: {
            VStack {
                switch searchState {
                case .none:
                    Text("Enter a search term to begin.")
                        .frame(maxHeight: .infinity)
                case .searching:
                    ProgressView()
                        .frame(maxHeight: .infinity)
                case .error:
                    Text("Sorry, your search failed – please check your internet connection and try again.")
                        .frame(maxHeight: .infinity)
                case .success:
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: gridItems) {
                            ForEach(tracks) { track in
                                TrackView(track: track, onSelected: play)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Fast Track (\(searchHistory.count))")
        }
        .searchable(text: $searchText)
        .onSubmit(of: .search, startSearch)
    }
    
    private func removeFromSearchHistory(_ term: String) {
        searchHistory.removeAll { $0 == term }
    }
    
    private func addToSearchHistory(_ term: String) {
        var history = searchHistory

        // Remove existing occurrence
        history.removeAll {
            $0.localizedCaseInsensitiveCompare(term) == .orderedSame
        }

        // Insert at the beginning
        history.insert(term, at: 0)

        // Keep only the latest 20 searches
        searchHistory = Array(history.prefix(20))
    }
    
    private func play(_ track: Track) {
        audioPlayer?.pause()
        audioPlayer = AVPlayer(url: track.previewUrl)
        audioPlayer?.play()
    }
    
    private func startSearch() {
        let term = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !term.isEmpty else { return }

        searchState = .searching

        Task {
            do {
                try await performSearch(term)

                addToSearchHistory(term)

                searchState = .success
            } catch {
                print("Error occurred while performing search: \(error)")
                searchState = .error
            }
        }
    }
    
    private func performSearch(_ term: String) async throws {
        var components = URLComponents(string: "https://itunes.apple.com/search")!

        components.queryItems = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "limit", value: "100"),
            URLQueryItem(name: "entity", value: "song")
        ]

        guard let url = components.url else { throw URLError(.badURL) }

        let (data, _) = try await URLSession.shared.data(from: url)

        let searchResults = try JSONDecoder().decode(SearchResult.self, from: data)

        tracks = searchResults.results
    }
    
    enum SearchState {
        case none, searching, success, error
    }
}

#Preview {
    ContentView()
}


