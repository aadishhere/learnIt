import SwiftUI

struct SummaryView: View {
    var summary: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("📘 Topic Summary")
                    .font(.title2.bold())
                    .padding(.horizontal)
                
                Text(summary)
                    .font(.body)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(white: 0.9), lineWidth: 1)
                    )
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Summary")
    }
}
