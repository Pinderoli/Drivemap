import SwiftUI

struct ActivityView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 44))
                    .foregroundStyle(.white.opacity(0.3))
                Text("Drive")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text("Your sessions and stats will appear here.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
            }
        }
    }
}
