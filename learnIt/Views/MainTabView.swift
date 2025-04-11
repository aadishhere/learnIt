import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Learn", systemImage: "book")
                }
            
            BookmarksView()
                .tabItem {
                    Label("Bookmarks", systemImage: "bookmark")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(.orange)
    }
}
