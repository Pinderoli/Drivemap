import CoreLocation
import Foundation

@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let clManager = CLLocationManager()

    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var currentLocation: CLLocation?
    var visitedLocations: [CLLocationCoordinate2D] = []
    var routeCoordinates: [CLLocationCoordinate2D] = []
    var visitedTiles: Set<TileID> = []

    override init() {
        super.init()
        clManager.delegate = self
        clManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        // TESTING: distanceFilter = 0 fires on every GPS fix (even stationary).
        // Tighten to 5 when moving to production.
        clManager.distanceFilter = kCLDistanceFilterNone

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

        // TESTING: relaxed to 100m so indoor/poor-signal GPS still records.
        // Tighten to 50 for production.
        guard location.horizontalAccuracy > 0, location.horizontalAccuracy < 100 else { return }

        currentLocation = location
        let coord = location.coordinate

        visitedLocations.append(coord)
        routeCoordinates.append(coord)
        visitedTiles.insert(TileID(coord))

        // Persist every 10 points to reduce I/O
        if visitedLocations.count % 10 == 0 {
            persistAll()
        }
    }

    // MARK: - Persistence

    private var visitedFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("visitedLocations.json")
    }

    private var routeFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("routeCoordinates.json")
    }

    private func persistAll() {
        let visited = visitedLocations.map { ["lat": $0.latitude, "lon": $0.longitude] }
        try? JSONSerialization.data(withJSONObject: visited).write(to: visitedFileURL)

        let route = routeCoordinates.map { ["lat": $0.latitude, "lon": $0.longitude] }
        try? JSONSerialization.data(withJSONObject: route).write(to: routeFileURL)
    }

    private func loadAll() {
        visitedLocations = load(from: visitedFileURL)
        routeCoordinates = load(from: routeFileURL)
        visitedTiles = Set(visitedLocations.map { TileID($0) })
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
