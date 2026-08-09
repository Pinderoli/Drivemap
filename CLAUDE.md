# Drivemap

A SwiftUI iOS app that reveals the map as you drive — a "fog of war" over
the UK that clears along roads you've actually travelled, plus stats on
how much of each UK region you've explored.

## Naming

- **Product / display name**: Drivemap (bundle ID `com.impossiblepossible.drivemap`).
- **Xcode target, source folders, and module name**: also `Drivemap` — the
  project was originally scaffolded as "Tarmac" and later renamed; as of
  this writing all folders, targets, and internal type names have been
  brought in line with the product name. If you see "Tarmac" reappear
  anywhere (new files copy-pasted from old templates, stale comments,
  user-facing strings), it's a leftover and should be renamed to match.

## Structure

```
Drivemap/                  Main app target
  DrivemapApp.swift         App entry point
  ContentView.swift         Root TabView (Drive / Explore / Map / Zones / Profile)
  Managers/
    LocationManager.swift    CoreLocation wrapper, tile tracking, persistence
  Models/
    TileID.swift              ~70m x 110m grid cell derived from a coordinate
    UKRegion.swift             Region polygon + completion/area math
    UKRegionsData.swift        Hardcoded simplified polygons for the 12 UK regions
  Overlays/
    FogOverlay.swift           MKOverlay marker for the dark map fog
    FogOverlayRenderer.swift   Draws the fog
  Views/
    MapView.swift              Live map: fog + glowing "driven road" polyline
    ExploreView.swift          Per-region completion map + list
    ActivityView.swift         Placeholder ("Drive" tab)
    ProfileView.swift          Placeholder
    SpeedZonesView.swift       Placeholder

DrivemapTests/              Swift Testing unit tests (currently empty scaffold)
DrivemapUITests/            XCUITest UI tests (currently empty scaffold)
```

## Current state

Only **Map** and **Explore** are functionally implemented. **Drive**,
**Profile**, and **Zones** are intentional placeholder screens ("will
appear here") — not bugs, just not built yet.

## Architecture notes

- `LocationManager` is the single source of GPS truth: it appends every
  accepted fix to `locations: [CLLocationCoordinate2D]`, derives
  `visitedTiles: Set<TileID>` from it, and persists `locations` to
  `locations.json` in the documents directory every 10 points. There is
  no session/trip concept yet — `locations` grows for the lifetime of the
  install.
- `visitedTiles` is what drives both the "explored" badge count and each
  `UKRegion`'s completion fraction (`UKRegion.contains` does ray-cast
  point-in-polygon against each tile's center).
- `MapView`'s `Coordinator` rebuilds the road glow/core polyline overlay
  from `locationManager.locations` whenever it grows by 5+ points (not on
  every fix — full rebuilds are O(n) in total points recorded, so this is
  deliberately throttled).
- Region polygons in `UKRegionsData.swift` are hand-simplified approximations,
  not OS Boundary-Line data — good enough for tile assignment, not for
  precise cartography. The file itself notes this.
- UK region area estimates assume a flat 12% "driveable road surface"
  fraction of land area for all regions (`UKRegion.driveableFraction`) —
  a rough placeholder, not measured per-region.

## Build

This is a standard Xcode project (`Drivemap.xcodeproj`, uses the modern
file-system-synchronized groups, so new files added to the folders on
disk are picked up automatically — no manual "add to target" step
needed). Requires Xcode with iOS 26 SDK; there's no CI/build tooling
configured in this repo yet, and no Swift toolchain is available in the
cloud dev sandbox this repo may be edited from — changes here are
reviewed by reading, not by compiling. Double-check anything touching
type/property names carefully since there's no build to catch typos.

- Signing team: `SAM7M445SP` (ImpossiblePossible Limited), automatic
  code signing.
- Deployment target: iOS 26.5.
