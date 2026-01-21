import SwiftUI

struct ActivitiesView: View {

    @StateObject private var viewModel = ActivitiesViewModel()

    var body: some View {
        ZStack {
            CamTimeStyle.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 16) {

                title

                activitiesCard

                addActivityBar
            }
            .padding()
        }
        .onAppear {
            viewModel.start()
        }
    }

    
    // MARK: - Title

    private var title: some View {
        Text("Our Activities 💕")
            .font(.system(size: 26, weight: .bold, design: .rounded))
            .foregroundColor(.pink)
    }

    
    // MARK: - Activities Card

    private var activitiesCard: some View {
        VStack(spacing: 12) {
            if viewModel.activities.isEmpty {
                Text("No activities yet 🌸")
                    .foregroundColor(.gray)
                    .padding(.vertical)
            } else {
                ForEach(viewModel.activities) { activity in
                    activityRow(activity)
                }
                .onDelete(perform: viewModel.delete)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(CamTimeStyle.cardBackground)
                .shadow(
                    color: .pink.opacity(0.2),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
    }

    
    // MARK: - Activity Row

    private func activityRow(_ activity: Activity) -> some View {
        HStack(spacing: 12) {

            Button {
                viewModel.toggle(activity)
            } label: {
                Image(systemName:
                        activity.isCompleted
                      ? "checkmark.circle.fill"
                      : "circle"
                )
                .font(.system(size: 22))
                .foregroundColor(
                    activity.isCompleted
                    ? .pink
                    : .pink.opacity(0.4)
                )
            }

            TextField(
                "Activity",
                text: Binding(
                    get: { activity.title },
                    set: { viewModel.updateTitle(activity, newTitle: $0) }
                )
            )
            .font(.system(size: 16, design: .rounded))
            .strikethrough(activity.isCompleted)
            .foregroundColor(
                activity.isCompleted
                ? .gray
                : .black
            )

            Spacer()
        }
        .padding(.vertical, 6)
    }

    
    // MARK: - Add Activity Bar

    private var addActivityBar: some View {
        HStack(spacing: 12) {

            TextField("New activity…", text: $viewModel.newActivityTitle)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.9))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.pink.opacity(0.3))
                )

            Button {
                viewModel.addActivity()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(14)
                    .background(
                        LinearGradient(
                            colors: [
                                Color.pink,
                                Color.pink.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(
                        color: .pink.opacity(0.3),
                        radius: 6,
                        x: 0,
                        y: 4
                    )
            }
            .disabled(viewModel.newActivityTitle.isEmpty)
            .opacity(viewModel.newActivityTitle.isEmpty ? 0.6 : 1)
        }
    }
}
