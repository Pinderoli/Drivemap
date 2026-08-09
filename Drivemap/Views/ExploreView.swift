import SwiftUI
import MapKit

struct ExploreView: View {
    @State private var locationManager = LocationManager()
    @State private var selectedRegion: UKRegion?

    private var sortedRegions: [UKRegion] {
        ukRegions.sorted {
            $0.completionFraction(visitedTiles: locationManager.visitedTiles) >
            $1.completionFraction(visitedTiles: locationManager.visitedTiles)
        }
    }

    private var totalExploredKm2: Double {
        ukRegions.reduce(0) { $0 + $1.exploredAreaKm2(visitedTiles: locationManager.visitedTiles) }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    // Header stats
                    HStack(spacing: 24) {
                        StatPill(label: "Explored", value: String(format: "%.1f km²", totalExploredKm2))
                        StatPill(label: "Tiles", value: "\(locationManager.visitedTiles.count)")
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                    // UK map with region overlays
                    UKRegionMap(visitedTiles: locationManager.visitedTiles, selectedRegion: $selectedRegion)
                        .frame(height: 380)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 16)

                    // Region list
                    VStack(spacing: 1) {
                        ForEach(sortedRegions) { region in
                            RegionRow(
                                region: region,
                                visitedTiles: locationManager.visitedTiles,
                                isSelected: selectedRegion?.id == region.id
                            )
                            .onTapGesture { selectedRegion = region }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationTitle("UK Explorer")
    }
}

// MARK: - UK Map

private struct UKRegionMap: UIViewRepresentable {
    let visitedTiles: Set<TileID>
    @Binding var selectedRegion: UKRegion?

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.isRotateEnabled = false
        map.isPitchEnabled = false
        map.mapType = .mutedStandard
        map.pointOfInterestFilter = .excludingAll
        map.showsBuildings = false
        map.showsTraffic = false

        // Preset to show all of UK + NI
        let center = CLLocationCoordinate2D(latitude: 54.8, longitude: -3.5)
        let span = MKCoordinateSpan(latitudeDelta: 12.0, longitudeDelta: 12.0)
        map.setRegion(MKCoordinateRegion(center: center, span: span), animated: false)

        // Add region overlays — London last so it renders on top
        // South East and East of England have London punched out as a hole
        let regionsFirst = ukRegions.filter { $0.id != "london" }
        let londonRegion = ukRegions.first { $0.id == "london" }

        for region in regionsFirst {
            let holes: [UKRegion] = (region.id == "south-east-england" || region.id == "east-of-england")
                ? (londonRegion.map { [$0] } ?? [])
                : []
            map.addOverlay(RegionPolygon(from: region, holes: holes), level: .aboveRoads)
        }
        if let london = londonRegion {
            map.addOverlay(RegionPolygon(from: london), level: .aboveRoads)
        }

        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        context.coordinator.update(visitedTiles: visitedTiles, selectedID: selectedRegion?.id)
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    // MARK: Coordinator

    final class Coordinator: NSObject, MKMapViewDelegate {
        var renderersByID: [String: RegionPolygonRenderer] = [:]

        func update(visitedTiles: Set<TileID>, selectedID: String?) {
            for (id, renderer) in renderersByID {
                guard let region = ukRegions.first(where: { $0.id == id }) else { continue }
                let fraction = region.completionFraction(visitedTiles: visitedTiles)
                let isSelected = id == selectedID
                renderer.update(completion: fraction, selected: isSelected)
            }
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let poly = overlay as? RegionPolygon else {
                return MKOverlayRenderer(overlay: overlay)
            }
            let renderer = RegionPolygonRenderer(polygon: poly)
            renderersByID[poly.regionID] = renderer
            return renderer
        }
    }
}

// MARK: - Custom Polygon + Renderer

final class RegionPolygon: MKPolygon {
    var regionID: String = ""

    convenience init(from region: UKRegion, holes: [UKRegion] = []) {
        var coords = region.polygon
        if holes.isEmpty {
            self.init(coordinates: &coords, count: coords.count)
        } else {
            let interiors = holes.map { hole -> MKPolygon in
                var hc = hole.polygon
                return MKPolygon(coordinates: &hc, count: hc.count)
            }
            self.init(coordinates: &coords, count: coords.count, interiorPolygons: interiors)
        }
        self.regionID = region.id
    }
}

final class RegionPolygonRenderer: MKPolygonRenderer {
    func update(completion: Double, selected: Bool) {
        let t = CGFloat(completion)
        // Unvisited = near-opaque dark overlay; explored = fades to near-transparent
        let fogAlpha: CGFloat = 0.82 - t * 0.75    // 0.82 → 0.07
        fillColor = UIColor(white: 0.08, alpha: fogAlpha)
        strokeColor = selected ? .white : UIColor(white: 1, alpha: 0.25)
        lineWidth = selected ? 1.5 : 0.5
        setNeedsDisplay()
    }
}

// MARK: - Region Row

private struct RegionRow: View {
    let region: UKRegion
    let visitedTiles: Set<TileID>
    let isSelected: Bool

    private var fraction: Double { region.completionFraction(visitedTiles: visitedTiles) }
    private var pct: String { String(format: "%.2f%%", fraction * 100) }
    private var km2: String { String(format: "%.1f km²", region.exploredAreaKm2(visitedTiles: visitedTiles)) }

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(region.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text(pct)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(fraction > 0 ? .orange : .white.opacity(0.3))
            }

            HStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(.white.opacity(0.08)).frame(height: 4)
                        Capsule()
                            .fill(fraction > 0 ? Color.orange : Color.clear)
                            .frame(width: geo.size.width * CGFloat(fraction), height: 4)
                    }
                }
                .frame(height: 4)

                Text(km2)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.35))
                    .frame(width: 60, alignment: .trailing)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(isSelected ? Color.white.opacity(0.06) : Color.clear)
    }
}

// MARK: - Stat Pill

private struct StatPill: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(minWidth: 100)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }
}
