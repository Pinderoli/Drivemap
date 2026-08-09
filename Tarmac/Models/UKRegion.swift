import CoreLocation
import MapKit

struct UKRegion: Identifiable {
    let id: String
    let name: String
    let polygon: [CLLocationCoordinate2D]
    let areaKm2: Double

    // Fraction of land that is driveable road surface (rough UK estimate)
    private static let driveableFraction = 0.12

    func totalEstimatedRoadTiles() -> Int {
        let lat = polygon.map(\.latitude).reduce(0, +) / Double(polygon.count)
        let tileArea = TileID.areaKm2(atLatitude: lat)
        return max(1, Int(areaKm2 * Self.driveableFraction / tileArea))
    }

    func completionFraction(visitedTiles: Set<TileID>) -> Double {
        let visited = visitedTiles.filter { contains($0.center) }.count
        return min(1.0, Double(visited) / Double(totalEstimatedRoadTiles()))
    }

    func visitedTileCount(in visitedTiles: Set<TileID>) -> Int {
        visitedTiles.filter { contains($0.center) }.count
    }

    func exploredAreaKm2(visitedTiles: Set<TileID>) -> Double {
        let count = visitedTileCount(in: visitedTiles)
        let lat = polygon.map(\.latitude).reduce(0, +) / Double(polygon.count)
        return Double(count) * TileID.areaKm2(atLatitude: lat)
    }

    func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        raycastPointInPolygon(coordinate, polygon: polygon)
    }
}

// Ray-casting point-in-polygon
private func raycastPointInPolygon(
    _ point: CLLocationCoordinate2D,
    polygon: [CLLocationCoordinate2D]
) -> Bool {
    guard polygon.count >= 3 else { return false }
    var inside = false
    var j = polygon.count - 1
    for i in 0..<polygon.count {
        let xi = polygon[i].longitude, yi = polygon[i].latitude
        let xj = polygon[j].longitude, yj = polygon[j].latitude
        if ((yi > point.latitude) != (yj > point.latitude)) &&
            (point.longitude < (xj - xi) * (point.latitude - yi) / (yj - yi) + xi) {
            inside = !inside
        }
        j = i
    }
    return inside
}

extension UKRegion {
    var mkPolygon: MKPolygon {
        var coords = polygon
        return MKPolygon(coordinates: &coords, count: coords.count)
    }
}
