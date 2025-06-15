import SwiftUI

struct MainView: View {
    enum Tab {
        case map, home, admin
    }

    @State private var selectedTab: Tab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .map:
                    MapView()
                case .admin:
                    AdminView()
                }
            }
            BottomNavBar(selectedTab: $selectedTab)
                .padding(.bottom, 20)
        }
    }
}

struct BottomNavBar: View {
    @Binding var selectedTab: MainView.Tab

    var body: some View {
        HStack(spacing: 40) {
            navButton(icon: "map", tab: .map)
            navButton(icon: "house", tab: .home)
            navButton(icon: "chart.bar", tab: .admin)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
        .shadow(radius: 5)
    }

    private func navButton(icon: String, tab: MainView.Tab) -> some View {
        Button(action: { selectedTab = tab }) {
            Image(systemName: icon + (selectedTab == tab ? ".fill" : ""))
                .font(.title2)
                .foregroundColor(selectedTab == tab ? .accentColor : .gray)
        }
    }
}

#Preview {
    MainView()
}
