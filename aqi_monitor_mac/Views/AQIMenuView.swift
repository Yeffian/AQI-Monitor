//
//  AQIMenu.swift
//  aqi_monitor_mac
//
//  Created by Adit Chakraborty on 15/10/2026.
//

import SwiftUI
import CoreLocation
import Combine
import ServiceManagement

struct AQIMenuView: View {
    @ObservedObject var model: AQIModel
 
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(model.aqi.map { "US AQI \($0)" } ?? "US AQI –")
                .font(.title2.bold())
            Text(model.status)
                .foregroundStyle(.secondary)
            AQIScaleBarView(aqi: model.aqi)
                .padding(.vertical, 4)
            HStack(spacing: 8) {
                PollutantTileView(name: "PM2.5", value: model.pm25)
                PollutantTileView(name: "PM10", value: model.pm10)
            }
            if let updated = model.lastUpdated {
                Text("Updated \(updated.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            Divider()
            Toggle("Launch at login", isOn: Binding(
                get: { launchAtLogin },
                set: { setLaunchAtLogin($0) }
            ))
            .toggleStyle(.switch)
            .controlSize(.small)
            if needsApproval {
                Button("Approve in System Settings…") {
                    SMAppService.openSystemSettingsLoginItems()
                }
                .buttonStyle(.link)
                .font(.caption)
            }
            Divider()
            HStack {
                Button("Refresh") { Task { await model.refresh() } }
                Spacer()
                Button("Quit") { NSApplication.shared.terminate(nil) }
            }
        }
        .padding()
        .frame(width: 260)
        .onAppear(perform: syncLoginStatus) // user may have changed it in System Settings
    }
 
    // MARK: Automatic Launch
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled
    @State private var needsApproval = SMAppService.mainApp.status == .requiresApproval
 
    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Launch at login change failed: \(error)")
        }
        syncLoginStatus()
    }
 
    private func syncLoginStatus() {
        let status = SMAppService.mainApp.status
        launchAtLogin = status == .enabled
        needsApproval = status == .requiresApproval
    }
}
