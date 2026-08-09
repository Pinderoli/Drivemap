import CoreLocation

// A ~70m × 110m grid cell in the UK (0.001° × 0.001°)
struct TileID: Hashable, Codable {
    let latIndex: Int
    let lonIndex: Int

    init(_ coordinate: CLLocationCoordinate2D) {
        latIndex = Int(floor(coordinate.latitude * 1000))
        lonIndex = Int(floor(coordinate.longitude * 1000))
    }

    var center: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: (Double(latIndex) + 0.5) / 1000,
            longitude: (Double(lonIndex) + 0.5) / 1000
        )
    }

    // Area of one tile in km² at UK latitudes (~51–58°N)
    static func areaKm2(atLatitude lat: Double) -> Double {
        let latHeight = 0.001 * 111.32
        let lonWidth  = 0.001 * 111.32 * cos(lat * .pi / 180)
        return latHeight * lonWidth
    }
}
