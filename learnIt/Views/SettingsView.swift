import SwiftUI

struct SettingsView: View {
    @AppStorage("appearance") var appearance = "light mode"
    @State private var cacheSize: String = "0 MB"
    @State private var showClearAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Logo
            HStack(spacing: 4) {
                Text("learn")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                Text("it")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.orange)
            }
            .padding(.top, 40)
            
            Spacer().frame(height: 30)
            
            // Settings section
            VStack(spacing: 12) {
                SettingRow(title: "Edit Profile")
                
                // Clear Cache Row with Action
                Button(action: {
                    showClearAlert = true
                }) {
                    SettingRow(title: "Clear Cache", trailing: cacheSize)
                }
                .buttonStyle(PlainButtonStyle())
                .alert("Clear all bookmarks?", isPresented: $showClearAlert) {
                    Button("Delete All", role: .destructive) {
                        UserDefaults.standard.saveBookmarks([])
                        cacheSize = "0 MB"
                    }
                    Button("Cancel", role: .cancel) {}
                }
                
                SettingRow(title: "App Version", trailing: "1.1 Dev")
                
                
                Button(action: {
                    // Handle logout action
                }) {
                    Text("Logout")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                }
                .padding(.top, 12)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .padding(.horizontal)
            .padding(.top, 16)
            
            Spacer()
            
            Text("Made in India 🇮🇳")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
        }
        .background(Color(white: 0.95).ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            calculateCacheSize()
        }
    }
    
    // MARK: - Cache Size Calculation
    func calculateCacheSize() {
        let bookmarks = UserDefaults.standard.loadBookmarks()
        if let data = try? JSONEncoder().encode(bookmarks) {
            let sizeInMB = Double(data.count) / 1024.0 / 1024.0
            cacheSize = String(format: "%.2f MB", sizeInMB)
        } else {
            cacheSize = "0 MB"
        }
    }
}

// MARK: - Setting Row
struct SettingRow: View {
    let title: String
    var trailing: String? = nil
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.black)
            Spacer()
            if let trailing = trailing {
                Text(trailing)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(white: 0.97))
        .cornerRadius(10)
    }
}

