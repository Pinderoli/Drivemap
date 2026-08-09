import SwiftUI

struct SpeedZonesView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "gauge.with.needle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white.opacity(0.3))
                Text("Speed Zones")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text("Speed zones and traps will appear here.\nStay close to the limit for the best score.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
        }
    }
}
