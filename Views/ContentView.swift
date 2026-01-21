import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = CamTimeViewModel()

    var body: some View {
        ZStack {
            background

            VStack {
                mainCard
            }
            .padding()
        }
        .onAppear {
            viewModel.start()
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color.pink.opacity(0.35),
                Color.pink.opacity(0.15),
                Color.white
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var mainCard: some View {
        VStack(spacing: 20) {

            Text("CamTime2")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.pink)

            Text(viewModel.data?.message ?? "—")
                .foregroundColor(.gray)

            if let days = viewModel.daysRemaining {
                Text("\(days)")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.pink)
            }

            TextField(
                "Write your response…",
                text: $viewModel.editedResponse
            )
            .textFieldStyle(.roundedBorder)

            Button("Send response 💕") {
                viewModel.saveResponse()
            }
            .disabled(!viewModel.canSendResponse)

            Button("Force refresh widget") {
                viewModel.forceRefresh()
            }
            .disabled(viewModel.isFetching)
        }
        .padding()
        .background(.white.opacity(0.85))
        .cornerRadius(24)
    }
}
