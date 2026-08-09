import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white.opacity(0.3))
                Text("Profile")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text("Your XP, level, and achievements will appear here.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
            }
        }
    }
}
