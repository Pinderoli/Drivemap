import MapKit

// Draws a uniform dark fog over the entire map.
// Road discovery is handled as a separate overlay drawn on top (see MapView).
// Area discovery circles have been removed — roads only.
final class FogOverlayRenderer: MKOverlayRenderer {

    // 0.50 = map visible at 50% brightness beneath the fog
    private let fogAlpha: CGFloat = 0.50

    override func canDraw(_ mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool { true }

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        context.setFillColor(UIColor(white: 0, alpha: fogAlpha).cgColor)
        context.fill(rect(for: mapRect))
    }
}
