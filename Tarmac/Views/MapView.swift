import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @State private var locationManager = LocationManager()

    var body: some View {
        ZStack(alignment: .topTrailing) {
            TarmacMapRepresentable(locationManager: locationManager)
                .ignoresSafeArea()

            VStack(spacing: 8) {
                if let speed = locationManager.currentLocation?.speed, speed > 0 {
                    SpeedBadge(speed: speed)
                }
                ExploredBadge(count: locationManager.visitedTiles.count)
            }
            .padding(.top, 60)
            .padding(.trailing, 16)
        }
        .onAppear {
            locationManager.requestPermission()
        }
        .overlay {
            if locationManager.authorizationStatus == .denied ||
               locationManager.authorizationStatus == .restricted {
                LocationDeniedOverlay()
            }
        }
    }
}

// MARK: - UIViewRepresentable

struct TarmacMapRepresentable: UIViewRepresentable {
    let locationManager: LocationManager

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.showsUserLocation = true
        map.userTrackingMode = .followWithHeading
        map.mapType = .mutedStandard
        map.pointOfInterestFilter = .excludingAll
        map.showsBuildings = false
        map.showsTraffic = false

        // Fog sits at aboveRoads so labels remain readable through it.
        // Road polylines are added at aboveLabels by the coordinator,
        // guaranteeing they always composite on top of the fog.
        map.addOverlay(FogOverlay(), level: .aboveRoads)
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        context.coordinator.sync(map: map, locationManager: locationManager)
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    // MARK: Coordinator

    final class Coordinator: NSObject, MKMapViewDelegate {
        private var glowPolyline: RoadGlowPolyline?
        private var corePolyline: RoadCorePolyline?
        private var lastRouteCount = 0

        func sync(map: MKMapView, locationManager: LocationManager) {
            let route = locationManager.locations
            // Rebuild the polyline every 5 new points to balance a responsive
            // line against the cost of a full overlay rebuild.
            guard route.count - lastRouteCount >= 5 else { return }
            lastRouteCount = route.count
            rebuildRoadLines(on: map, coordinates: route)
        }

        private func rebuildRoadLines(on map: MKMapView, coordinates: [CLLocationCoordinate2D]) {
            if let g = glowPolyline { map.removeOverlay(g) }
            if let c = corePolyline { map.removeOverlay(c) }
            guard coordinates.count >= 2 else { return }

            var coords = coordinates

            // Both overlays at aboveLabels — added AFTER the fog (aboveRoads),
            // so MapKit always composites them on top of the fog layer.
            let glow = RoadGlowPolyline(coordinates: &coords, count: coords.count)
            let core = RoadCorePolyline(coordinates: &coords, count: coords.count)
            glowPolyline = glow
            corePolyline = core
            map.addOverlay(glow, level: .aboveLabels)
            map.addOverlay(core, level: .aboveLabels)
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            switch overlay {
            case let fog as FogOverlay:
                return FogOverlayRenderer(overlay: fog)

            case let glow as RoadGlowPolyline:
                let r = MKPolylineRenderer(polyline: glow)
                // Wide, soft halo behind the solid core line below
                r.strokeColor = UIColor.white.withAlphaComponent(0.22)
                r.lineWidth = 24
                r.lineCap = .round
                r.lineJoin = .round
                return r

            case let core as RoadCorePolyline:
                let r = MKPolylineRenderer(polyline: core)
                // Bright solid core — the "driven road" line
                r.strokeColor = .white
                r.lineWidth = 8
                r.lineCap = .round
                r.lineJoin = .round
                return r

            default:
                return MKOverlayRenderer(overlay: overlay)
            }
        }
    }
}

// Typed subclasses so rendererFor can distinguish them without extra state
final class RoadGlowPolyline: MKPolyline {}
final class RoadCorePolyline: MKPolyline {}

// MARK: - HUD

private struct SpeedBadge: View {
    let speed: Double
    private var mph: Int { Int(max(0, speed) * 2.23694) }

    var body: some View {
        VStack(spacing: 0) {
            Text("\(mph)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("MPH")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(width: 64, height: 64)
        .background(.black.opacity(0.7), in: Circle())
        .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
    }
}

private struct ExploredBadge: View {
    let count: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "road.lanes")
                .font(.system(size: 11, weight: .semibold))
            Text("\(count) tiles")
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(.white.opacity(0.8))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.black.opacity(0.65), in: Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.15), lineWidth: 1))
    }
}

private struct LocationDeniedOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "location.slash.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.white.opacity(0.6))
                Text("Location Access Required")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                Text("Tarmac tracks your location to reveal the map as you drive.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.white)
                .foregroundStyle(.black)
            }
        }
    }
}
