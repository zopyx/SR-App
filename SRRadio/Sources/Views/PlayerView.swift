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
    @StateObject private var audioPlayer = AudioPlayer()
    @StateObject private var nowPlayingService = NowPlayingService()
    
    @State private var selectedStation: Station = Station.defaultStation
    @State private var showStationSelector = false
    @State private var showAbout = false
    @State private var showSettings = false
    @State private var isHoveringLogo = false

    private let logoContainerSize: CGFloat = 240
    private let logoImageSize: CGFloat = 170
    private let stationNameSize: CGFloat = 26
    private let trackInfoHeight: CGFloat = 90
    
    private var isPlaying: Bool {
        if case .playing = audioPlayer.state { return true }
        return false
    }
    
    private var isLoading: Bool {
        if case .loading = audioPlayer.state { return true }
        return false
    }
    
    private var errorMessage: String? {
        if case .error(let msg) = audioPlayer.state { return msg }
        return nil
    }
    
    var body: some View {
        ZStack {
            DynamicBackground(color: selectedStation.color)
            
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Button(action: {
                        withAnimation {
                            showSettings = true
                        }
                    }) {
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
                        selectedStation: $selectedStation,
                        isExpanded: $showStationSelector,
                        stations: Station.all
                    ) { newStation in
                        changeStation(to: newStation)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            showAbout = true
                        }
                    }) {
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
                
                // Artwork
                logoButton
                    .padding(.vertical, 16)
                    .zIndex(1)
                
                // Track Info
                VStack(spacing: 8) {
                    Text(selectedStation.name)
                        .font(.system(size: stationNameSize, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.3), radius: 2, y: 1)
                    
                    NowPlayingView(
                        data: nowPlayingService.currentData,
                        isLoading: nowPlayingService.isLoading,
                        stationColor: selectedStation.color
                    )
                }
                .padding(.horizontal, 20)
                .frame(height: trackInfoHeight)
                .zIndex(1)
                
                if let error = errorMessage {
                    ErrorMessageView(message: error) {
                        audioPlayer.state = .idle
                    }
                    .padding(.top, 4)
                }
                
                Spacer()
                
                // Volume & Status
                VStack(spacing: 12) {
                    VolumeControl(
                        volume: $audioPlayer.volume,
                        isMuted: $audioPlayer.isMuted,
                        stationColor: selectedStation.color,
                        onMuteToggle: { audioPlayer.toggleMute() }
                    )

                    StatusIndicator(
                        isPlaying: isPlaying,
                        isLoading: isLoading,
                        stationColor: selectedStation.color
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

            if showAbout {
                AboutView(
                    isPresented: $showAbout,
                    currentStation: selectedStation,
                    nowPlayingData: nowPlayingService.currentData
                )
                .transition(.opacity)
                .zIndex(3)
            }
            
            if showSettings {
                SettingsView(isPresented: $showSettings)
                    .transition(.opacity)
                    .zIndex(3)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            audioPlayer.loadStation(selectedStation, autoPlay: true)
            nowPlayingService.startMonitoring(station: selectedStation)
        }
        .onChange(of: audioPlayer.state) { newState in
            if #available(iOS 16.2, *) {
                updateLiveActivity(state: newState)
            }
        }
        .onChange(of: nowPlayingService.currentData) { _ in
            if #available(iOS 16.2, *) {
                updateLiveActivity(state: audioPlayer.state)
            }
        }
    }
    
    private var logoButton: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .background(VisualEffectView().clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous)))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                )
                .shadow(color: selectedStation.color.opacity(0.4), radius: 24, x: 0, y: 10)
                .shadow(color: Color.black.opacity(0.5), radius: 12, x: 0, y: 6)
            
            StationLogo(station: selectedStation, size: logoImageSize)
                .opacity(isLoading ? 0.3 : 1.0)
                .shadow(color: Color.white.opacity(0.1), radius: 10)
            
            if isLoading {
                LoadingSpinner(color: .white)
            } else if !isPlaying {
                Image(systemName: "play.fill")
                    .font(.system(size: 54, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 2)
                    .opacity(isHoveringLogo ? 1 : 0)
                    .animation(.easeOut(duration: 0.2), value: isHoveringLogo)
            }
            
            if isPlaying {
                VStack {
                    Spacer()
                    EqualizerView(color: .white)
                        .padding(.bottom, 20)
                }
            }
        }
        .frame(width: logoContainerSize, height: logoContainerSize)
        .onHover { hovering in
            isHoveringLogo = hovering
        }
        .onTapGesture {
            audioPlayer.togglePlayPause()
            Haptics.playPause()
        }
        .scaleEffect(isHoveringLogo ? 1.02 : (isPlaying ? 1.0 : 0.98))
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isHoveringLogo)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isPlaying)
    }
    
    private func changeStation(to station: Station) {
        selectedStation = station
        audioPlayer.loadStation(station, autoPlay: true)
        nowPlayingService.startMonitoring(station: station)
        Station.saveLastPlayed(station)
        Haptics.stationChange()

        if #available(iOS 16.2, *) {
            restartLiveActivity(for: station)
        }
    }

    @available(iOS 16.2, *)
    private func restartLiveActivity(for station: Station) {
        LiveActivityManager.shared.endActivity()
        let contentState = SRRadioAttributes.ContentState(
            isPlaying: true,
            title: "",
            artist: "",
            show: ""
        )
        LiveActivityManager.shared.startActivity(station: station, state: contentState)
    }

    @available(iOS 16.2, *)
    private func updateLiveActivity(state: PlaybackState) {
        let data = nowPlayingService.currentData

        switch state {
        case .playing:
            let contentState = SRRadioAttributes.ContentState(
                isPlaying: true,
                title: data?.title ?? "",
                artist: data?.artist ?? "",
                show: data?.show ?? ""
            )
            if LiveActivityManager.shared.currentActivity == nil {
                LiveActivityManager.shared.startActivity(station: selectedStation, state: contentState)
            } else {
                LiveActivityManager.shared.updateActivity(state: contentState)
            }
        case .paused:
            let contentState = SRRadioAttributes.ContentState(
                isPlaying: false,
                title: data?.title ?? "",
                artist: data?.artist ?? "",
                show: data?.show ?? ""
            )
            LiveActivityManager.shared.updateActivity(state: contentState)
        case .idle:
            LiveActivityManager.shared.endActivity()
        case .loading, .error:
            break
        }
    }
}

struct PlayOverlay: View {
    let color: Color
    var body: some View { EmptyView() } // Superseded by direct image in logoButton
}

struct LoadingSpinner: View {
    let color: Color
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 3)
            
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(color, lineWidth: 3)
                .rotationEffect(.degrees(rotation))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotation)
        }
        .frame(width: 48, height: 48)
        .onAppear {
            rotation = 360
        }
    }
}

struct ErrorMessageView: View {
    let message: String
    let onDismiss: () -> Void
    @State private var shakeOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 12))
            
            Text(message)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(Color(red: 1, green: 0.42, blue: 0.42))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 1, green: 0.27, blue: 0.27).opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
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
        .onTapGesture {
            onDismiss()
        }
    }
}
