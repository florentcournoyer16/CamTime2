import SwiftUI


struct RootTabView: View {

    init() {
        UITabBar.appearance().tintColor = .systemPink
        UITabBar.appearance().unselectedItemTintColor =
            UIColor.systemPink.withAlphaComponent(0.5)
    }

    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("CamTime", systemImage: "heart.fill")
                }

            ActivitiesView()
                .tabItem {
                    Label("Activities", systemImage: "checklist")
                }
        }
    }
}

