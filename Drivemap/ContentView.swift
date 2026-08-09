//
//  ContentView.swift
//  Drivemap
//
//  Created by Oliver Pinder on 24/07/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 2

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(white: 0.4, alpha: 1)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(white: 0.4, alpha: 1)]
        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ActivityView()
                .tabItem { Label("Drive", systemImage: "waveform.path.ecg") }
                .tag(0)

            ExploreView()
                .tabItem { Label("Explore", systemImage: "binoculars.fill") }
                .tag(1)

            MapView()
                .tabItem { Label("Map", systemImage: "map.fill") }
                .tag(2)

            SpeedZonesView()
                .tabItem { Label("Zones", systemImage: "gauge.with.needle.fill") }
                .tag(3)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.circle.fill") }
                .tag(4)
        }
        .tint(.white)
    }
}

#Preview {
    ContentView()
}
