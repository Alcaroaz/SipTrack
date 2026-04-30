import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            CalendarTabView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendario")
                }
                .tag(0)

            DrinkCategorySelectionView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Registrar")
                }
                .tag(1)
        }
        .tint(.primary)
    }
}

#Preview {
    MainTabView()
}
