//
//  aqi_monitor_macApp.swift
//  aqi_monitor_mac
//
//  Created by Adit Chakraborty on 15/10/2026.
//

import SwiftUI

@main
struct aqi_monitor_macApp: App {
    @StateObject private var model = AQIModel()

    var body: some Scene {
        MenuBarExtra {
            AQIMenuView(model: model)
        } label: {
            Text(model.menuBarLabel)
        }
        .menuBarExtraStyle(.window)
    }
}

