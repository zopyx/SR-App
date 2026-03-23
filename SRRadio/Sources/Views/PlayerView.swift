import SwiftUI

struct DynamicBackground: View {
    let color: Color

    var body: some View {
        ZStack {
            Color(white: 0.08)

            color
                .opacity(0.2)
                .blendMode(.overlay)

            LinearGradient(
                colors: [color.opacity(0.15), Color.black.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [color.opacity(0.2), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 400
            )
            .blendMode(.screen)
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 1.0), value: color)
    }
}

struct PlayerView: View {
    @StateObject private var viewModel = PlayerViewModel()

    private let logoContainerSize: CGFloat = 240
    private let logoImageSize: CGFloat = 170
    private let stationNameSize: CGFloat = 26
    private let trackInfoHeight: CGFloat = 90

    var body: some View {
        ZStack {
            DynamicBackground(color: viewModel.selectedStation.color)

            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Button(action: viewModel.openSettings) {
                        Image(systemName: "gear")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.95))
                            .frame(width: 28, height: 28)
                            .background(Color.black.opacity(0.35))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.2), radius: 2)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()

                    StationSelector(
                        selectedStation: $viewModel.selectedStation,
                        isExpanded: $viewModel.showStationSelector,
                        stations: Station.all
                    ) { newStation in
                        viewModel.changeStation(to: newStation)
                    }

                    Spacer()

                    Button(action: viewModel.openAbout) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.95))
                            .frame(width: 28, height: 28)
                            .background(Color.black.opacity(0.35))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.2), radius: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 22)
                .padding(.top, 16)
                .zIndex(2)

                Spacer()

                // Artwork with state-based overlay
                logoButton
                    .padding(.vertical, 16)
                    .zIndex(1)

                // Track Info
                VStack(spacing: 8) {
                    Text(viewModel.selectedStation.name)
                        .font(.system(size: stationNameSize, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.3), radius: 2, y: 1)

                    NowPlayingView(
                        data: viewModel.nowPlayingService.currentData,
                        isLoading: viewModel.isBuffering,
                        stationColor: viewModel.selectedStation.color
                    )
                }
                .padding(.horizontal, 20)
                .frame(height: trackInfoHeight)
                .zIndex(1)

                if let error = viewModel.userErrorMessage {
                    ErrorMessageView(message: error) {
                        viewModel.dismissError()
                    }
                    .padding(.top, 4)
                }

                Spacer()

                // Volume & Status
                VStack(spacing: 16) {
                    VolumeControl(
                        volume: $viewModel.volume,
                        isMuted: $viewModel.isMuted,
                        stationColor: viewModel.selectedStation.color,
                        onMuteToggle: { viewModel.audioPlayer.toggleMute() }
                    )

                    // New status indicator showing all 4 states
                    StatusIndicatorView(
                        state: viewModel.playerState,
                        stationColor: viewModel.selectedStation.color
                    )
                    .padding(.bottom, 4)

                    Text("Saar Streams")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.3))
                        .tracking(2)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .zIndex(1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if viewModel.showAbout {
                AboutView(
                    isPresented: $viewModel.showAbout,
                    currentStation: viewModel.selectedStation,
                    nowPlayingData: viewModel.nowPlayingService.currentData
                )
                .transition(.opacity)
                .zIndex(3)
            }

            if viewModel.showSettings {
                SettingsView(isPresented: $viewModel.showSettings)
                    .transition(.opacity)
                    .zIndex(3)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            viewModel.onViewAppear()
        }
        .onChange(of: viewModel.playerState) { _ in
            viewModel.onPlaybackStateChange()
        }
        .onChange(of: viewModel.nowPlayingService.currentData) { _ in
            viewModel.onNowPlayingChange()
        }
    }

    private var logoButton: some View {
        ZStack {
            // Background card
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .background(VisualEffectView().clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous)))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                )
                .shadow(color: viewModel.selectedStation.color.opacity(0.4), radius: 24, x: 0, y: 10)
                .shadow(color: Color.black.opacity(0.5), radius: 12, x: 0, y: 6)

            // Station logo
            StationLogo(station: viewModel.selectedStation, size: logoImageSize)
                .opacity(viewModel.isBuffering ? 0.4 : 1.0)
                .shadow(color: Color.white.opacity(0.1), radius: 10)

            // Loading spinner - only shows during buffering
            LoadingSpinnerView(
                isVisible: viewModel.isBuffering,
                color: viewModel.selectedStation.color
            )

            // Play button overlay - shows when not playing and not buffering
            if !viewModel.isPlaying && !viewModel.isBuffering {
                Image(systemName: "play.fill")
                    .font(.system(size: 54, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 2)
                    .opacity(viewModel.isHoveringLogo ? 1 : 0)
                    .animation(.easeOut(duration: 0.2), value: viewModel.isHoveringLogo)
            }

            // Equalizer - only shows when actively playing
            if viewModel.isPlaying {
                VStack {
                    Spacer()
                    EqualizerView(color: .white)
                        .padding(.bottom, 20)
                }
            }
        }
        .frame(width: logoContainerSize, height: logoContainerSize)
        .onHover { hovering in
            viewModel.isHoveringLogo = hovering
        }
        .onTapGesture {
            viewModel.audioPlayer.togglePlayPause()
            Haptics.playPause()
        }
        .scaleEffect(viewModel.isHoveringLogo ? 1.02 : (viewModel.isPlaying ? 1.0 : 0.98))
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: viewModel.isHoveringLogo)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: viewModel.isPlaying)
    }
}

struct ErrorMessageView: View {
    let message: String
    let onDismiss: () -> Void
    @State private var shakeOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 12))

                Text("Stream nicht verfügbar")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(Color(red: 1, green: 0.42, blue: 0.42))

            Text(message)
                .font(.system(size: 11))
                .foregroundColor(Color.white.opacity(0.7))
                .multilineTextAlignment(.center)

            Button(action: onDismiss) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11, weight: .semibold))
                    Text("Erneut versuchen")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(red: 1, green: 0.27, blue: 0.27))
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 1, green: 0.27, blue: 0.27).opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 1, green: 0.27, blue: 0.27).opacity(0.3), lineWidth: 1)
                )
        )
        .offset(x: shakeOffset)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.1).repeatCount(5)) {
                shakeOffset = 5
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                shakeOffset = 0
            }
        }
    }
}
