import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("CamTime")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("This app only exists to host the widget ❤️")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
