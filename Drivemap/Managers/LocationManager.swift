import CoreLocation
import Foundation

@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let clManager = CLLocationManager()

    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var currentLocation: CLLocation?
    var locations: [CLLocationCoordinate2D] = []
    var visitedTiles: Set<TileID> = []

    override init() {
        super.init()
        clManager.delegate = self
        clManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        clManager.distanceFilter = 5

        authorizationStatus = clManager.authorizationStatus
        loadAll()
    }

    func requestPermission() {
        clManager.requestWhenInUseAuthorization()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        guard location.horizontalAccuracy > 0, location.horizontalAccuracy < 50 else { return }

        currentLocation = location
        let coord = location.coordinate

        self.locations.append(coord)
        visitedTiles.insert(TileID(coord))

        // Persist every 10 points to reduce I/O
        if self.locations.count % 10 == 0 {
            persistAll()
        }
    }

    // MARK: - Persistence

    private var locationsFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("locations.json")
    }

    private func persistAll() {
        let encoded = locations.map { ["lat": $0.latitude, "lon": $0.longitude] }
        try? JSONSerialization.data(withJSONObject: encoded).write(to: locationsFileURL)
    }

    private func loadAll() {
        locations = load(from: locationsFileURL)
        visitedTiles = Set(locations.map { TileID($0) })
    }

    private func load(from url: URL) -> [CLLocationCoordinate2D] {
        guard let data = try? Data(contentsOf: url),
              let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Double]]
        else { return [] }
        return array.compactMap { dict in
            guard let lat = dict["lat"], let lon = dict["lon"] else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
    }
}
