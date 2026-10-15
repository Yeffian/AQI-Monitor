//
//  AQIModel.swift
//  aqi_monitor_mac
//
//  Created by Adit Chakraborty on 15/10/2026.
//

import SwiftUI
import CoreLocation
import Combine

@MainActor
final class AQIModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var aqi: Int?
    @Published var pm25: Double?
    @Published var pm10: Double?
    @Published var status = "Locating…"
    @Published var lastUpdated: Date?
 
    private let manager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var timer: Timer?
 
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.distanceFilter = 1000 //theres no point refetching data if they moved less than a km
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
 
        //refresh every 15 mins, same as API
        timer = Timer.scheduledTimer(withTimeInterval: 15 * 60, repeats: true) { [weak self] _ in
            Task { @MainActor in await self?.refresh() }
        }
    }
 
    var menuBarLabel: String {
        guard let aqi else { return "AQI –" }
        return "\(Self.dot(for: aqi)) \(aqi)"
    }
 
    // MARK: Location Stuff
 
    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        Task { @MainActor in
            self.lastLocation = loc
            await self.refresh()
        }
    }
 
    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didFailWithError error: Error) {
        Task { @MainActor in self.status = "Location unavailable" }
    }
 
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let s = manager.authorizationStatus
        Task { @MainActor in
            if s == .denied || s == .restricted {
                self.status = "Location access denied"
            }
        }
    }
 
    // MARK: API requests
    private struct Response: Decodable {
        struct Current: Decodable {
            let us_aqi: Double?
            let pm2_5: Double?
            let pm10: Double?
        }
        let current: Current
    }
 
    func refresh() async {
        guard let c = lastLocation?.coordinate else { return }
 
        var comps = URLComponents(string: "https://air-quality-api.open-meteo.com/v1/air-quality")!
        comps.queryItems = [
            URLQueryItem(name: "latitude", value: String(c.latitude)),
            URLQueryItem(name: "longitude", value: String(c.longitude)),
            URLQueryItem(name: "current", value: "us_aqi,pm2_5,pm10")
        ]
 
        do {
            let (data, _) = try await URLSession.shared.data(from: comps.url!)
            let decoded = try JSONDecoder().decode(Response.self, from: data)
            pm25 = decoded.current.pm2_5
            pm10 = decoded.current.pm10
            guard let value = decoded.current.us_aqi else {
                status = "No AQI data here"
                return
            }
            let rounded = Int(value.rounded())
            aqi = rounded
            status = Self.category(for: rounded)
            lastUpdated = Date()
        } catch {
            status = "Couldn't fetch AQI"
        }
    }
  
    static func category(for aqi: Int) -> String {
        switch aqi {
        case ..<51:    return "Good"
        case 51...100: return "Moderate"
        case 101...150: return "Unhealthy for sensitive groups"
        case 151...200: return "Unhealthy"
        case 201...300: return "Very unhealthy"
        default:       return "Hazardous"
        }
    }
 
    static func dot(for aqi: Int) -> String {
        switch aqi {
        case ..<51:    return "✅"
        case 51...100: return "⚠️"
        case 101...150: return "🟧"
        case 151...200: return "🚩"
        case 201...300: return "🟪"
        default:       return "🚨" //seriously hope I don't see this any time soon
        }
    }
}
