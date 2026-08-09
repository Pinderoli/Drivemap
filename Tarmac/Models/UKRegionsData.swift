import CoreLocation

// Simplified polygon boundaries for UK administrative regions.
// Coordinates are approximate — accurate enough for tile assignment and display.
// For county-level precision, replace with OS Boundary-Line GeoJSON.

let ukRegions: [UKRegion] = [
    .northEast, .northWest, .yorkshire,
    .eastMidlands, .westMidlands, .eastOfEngland,
    .london, .southEast, .southWest,
    .wales, .scotland, .northernIreland,
]

private func coords(_ pairs: [(Double, Double)]) -> [CLLocationCoordinate2D] {
    pairs.map { CLLocationCoordinate2D(latitude: $0.0, longitude: $0.1) }
}

extension UKRegion {

    // MARK: - England Regions

    static let northEast = UKRegion(
        id: "north-east-england",
        name: "North East",
        polygon: coords([
            (55.82, -2.08),
            (55.82, -1.72),
            (55.58, -1.38),
            (55.22, -1.20),
            (54.98, -1.15),
            (54.62, -1.18),
            (54.55, -1.58),
            (54.52, -2.20),
            (54.72, -2.42),
            (55.05, -2.58),
            (55.42, -2.65),
            (55.65, -2.40),
        ]),
        areaKm2: 8600
    )

    static let northWest = UKRegion(
        id: "north-west-england",
        name: "North West",
        polygon: coords([
            (55.00, -2.42),
            (55.00, -3.08),
            (54.65, -3.52),
            (54.35, -3.22),
            (54.05, -3.45),
            (53.72, -3.12),
            (53.52, -3.02),
            (53.28, -3.05),
            (53.18, -2.78),
            (53.28, -2.62),
            (53.42, -2.12),
            (53.82, -2.10),
            (54.35, -2.10),
            (54.52, -2.20),
            (54.72, -2.42),
        ]),
        areaKm2: 14_165
    )

    static let yorkshire = UKRegion(
        id: "yorkshire",
        name: "Yorkshire & Humber",
        polygon: coords([
            (54.62, -1.18),
            (54.62, -0.85),
            (54.47, -0.38),
            (54.10,  0.05),
            (53.58,  0.12),
            (53.55, -0.42),
            (53.35, -0.68),
            (53.35, -1.55),
            (53.42, -2.12),
            (53.82, -2.10),
            (54.35, -2.10),
            (54.52, -2.20),
            (54.55, -1.58),
        ]),
        areaKm2: 15_420
    )

    static let eastMidlands = UKRegion(
        id: "east-midlands",
        name: "East Midlands",
        polygon: coords([
            (53.35, -1.55),
            (53.35, -0.68),
            (53.20,  0.10),
            (52.88,  0.25),
            (52.55,  0.25),
            (52.18, -0.32),
            (52.05, -0.78),
            (52.05, -1.32),
            (52.18, -1.72),
            (52.50, -1.78),
            (52.88, -1.85),
            (53.18, -1.92),
            (53.35, -1.78),
        ]),
        areaKm2: 15_627
    )

    static let westMidlands = UKRegion(
        id: "west-midlands",
        name: "West Midlands",
        polygon: coords([
            (53.18, -1.92),
            (52.88, -1.85),
            (52.50, -1.78),
            (52.18, -1.72),
            (52.05, -1.32),
            (51.98, -2.08),
            (51.85, -2.72),
            (51.98, -2.88),
            (52.28, -2.98),
            (52.52, -2.95),
            (52.82, -2.88),
            (53.02, -2.68),
            (53.18, -2.48),
        ]),
        areaKm2: 13_004
    )

    static let eastOfEngland = UKRegion(
        id: "east-of-england",
        name: "East of England",
        polygon: coords([
            (53.20,  0.10),
            (52.88,  0.25),
            (52.55,  0.25),
            (52.50,  0.38),
            (52.48,  1.75),
            (52.28,  1.72),
            (51.92,  1.28),
            (51.55,  0.82),
            (51.48,  0.50),
            (51.48,  0.12),
            (51.62, -0.25),
            (51.85, -0.48),
            (52.05, -0.78),
            (52.18, -0.32),
            (52.55,  0.25),
        ]),
        areaKm2: 19_120
    )

    static let london = UKRegion(
        id: "london",
        name: "London",
        polygon: coords([
            (51.70, -0.52),
            (51.70,  0.02),
            (51.70,  0.32),
            (51.58,  0.40),
            (51.40,  0.25),
            (51.28,  0.00),
            (51.28, -0.28),
            (51.38, -0.52),
            (51.52, -0.52),
        ]),
        areaKm2: 1572
    )

    static let southEast = UKRegion(
        id: "south-east-england",
        name: "South East",
        polygon: coords([
            (51.70, -1.58),
            (51.70, -1.02),
            (51.70, -0.52),
            (51.38, -0.52),
            (51.28, -0.28),
            (51.28,  0.00),
            (51.08,  0.38),
            (51.08,  1.42),
            (51.05,  1.12),
            (50.78,  0.55),
            (50.68, -0.78),
            (50.55, -1.18),
            (50.58, -1.92),
            (50.72, -2.08),
            (51.05, -2.22),
            (51.22, -2.12),
            (51.38, -1.82),
            (51.50, -1.68),
        ]),
        areaKm2: 27_219
    )

    static let southWest = UKRegion(
        id: "south-west-england",
        name: "South West",
        polygon: coords([
            (51.80, -2.55),
            (51.65, -2.55),
            (51.42, -2.65),
            (51.22, -2.12),
            (51.05, -2.22),
            (50.72, -2.08),
            (50.55, -2.45),
            (50.55, -3.48),
            (50.20, -3.68),
            (50.02, -5.08),
            (50.15, -5.72),
            (50.32, -5.18),
            (50.65, -4.82),
            (51.18, -5.02),
            (51.22, -4.22),
            (51.22, -3.18),
            (51.52, -2.95),
        ]),
        areaKm2: 23_829
    )

    // MARK: - Devolved Nations

    static let wales = UKRegion(
        id: "wales",
        name: "Wales",
        polygon: coords([
            (53.40, -2.65),
            (53.42, -3.05),
            (53.27, -4.65),
            (52.82, -4.78),
            (52.42, -4.98),
            (51.82, -5.12),
            (51.68, -5.08),
            (51.52, -4.52),
            (51.42, -3.38),
            (51.42, -2.65),
            (51.65, -2.55),
            (51.80, -2.55),
            (52.00, -2.85),
            (52.58, -3.05),
            (52.92, -3.35),
        ]),
        areaKm2: 20_779
    )

    static let scotland = UKRegion(
        id: "scotland",
        name: "Scotland",
        polygon: coords([
            (55.00, -2.00),
            (55.82, -1.72),
            (56.00, -2.45),
            (56.45, -2.38),
            (57.05, -2.08),
            (57.52, -2.00),
            (57.72, -3.98),
            (58.35, -5.00),
            (58.70, -4.40),
            (58.52, -3.08),
            (58.68, -2.98),
            (58.52, -5.22),
            (57.60, -5.72),
            (56.70, -6.15),
            (55.35, -5.18),
            (54.90, -5.15),
            (55.00, -2.00),
        ]),
        areaKm2: 77_933
    )

    static let northernIreland = UKRegion(
        id: "northern-ireland",
        name: "Northern Ireland",
        polygon: coords([
            (55.35, -5.20),
            (55.45, -6.08),
            (55.30, -6.52),
            (55.20, -7.80),
            (54.55, -8.20),
            (54.05, -7.85),
            (54.00, -6.32),
            (54.28, -5.45),
            (54.70, -5.20),
        ]),
        areaKm2: 13_562
    )
}
