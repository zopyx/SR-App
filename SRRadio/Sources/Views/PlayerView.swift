import SwiftUI

struct PlayerView: View {
    @StateObject private var audioPlayer = AudioPlayer()
    @StateObject private var nowPlayingService = NowPlayingService()
    
    @State private var selectedStation: Station = .default
    @State private var showStationSelector = false
    @State private var showAbout = false
    @State private var isHoveringLogo = false
    
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
            VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
                .ignoresSafeArea()
            
            LinearGradient(
                colors: [Color.black.opacity(0.1), Color.black.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)
            
            VStack(spacing: 12) {
                HStack {
                    StationSelector(
                        selectedStation: $selectedStation,
                        isExpanded: $showStationSelector,
                        stations: Station.all
                    ) { newStation in
                        changeStation(to: newStation)
                    }
                    
                    Spacer()
                    
                    // Info button
                    Button(action: {
                        withAnimation {
                            showAbout = true
                        }
                    }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 16))
                            .foregroundColor(selectedStation.color)
                            .frame(width: 28, height: 28)
                            .background(
                                Circle()
                                    .fill(selectedStation.color.opacity(0.1))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                Spacer()
                
                logoButton
                    .padding(.vertical, 10)
                
                Text(selectedStation.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(selectedStation.color)
                
                NowPlayingView(
                    data: nowPlayingService.currentData,
                    isLoading: nowPlayingService.isLoading,
                    stationColor: selectedStation.color
                )
                
                if let error = errorMessage {
                    ErrorMessageView(message: error) {
                        audioPlayer.state = .idle
                    }
                }
                
                Spacer()
                
                VolumeControl(
                    volume: $audioPlayer.volume,
                    isMuted: $audioPlayer.isMuted,
                    stationColor: selectedStation.color,
                    onMuteToggle: { audioPlayer.toggleMute() }
                )
                .padding(.horizontal, 20)
                
                StatusIndicator(
                    isPlaying: isPlaying,
                    isLoading: isLoading,
                    stationColor: selectedStation.color
                )
                .padding(.bottom, 16)
            }
            .frame(width: 320, height: 400)
            
            if showAbout {
                AboutView(
                    isPresented: $showAbout,
                    currentStation: selectedStation,
                    nowPlayingData: nowPlayingService.currentData,
                    onStationChange: { station in
                        changeStation(to: station)
                    }
                )
                .transition(.opacity)
            }
        }
        .frame(width: 320, height: 400)
        .onAppear {
            audioPlayer.loadStation(selectedStation, autoPlay: true)
            nowPlayingService.startMonitoring(station: selectedStation)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowAbout"))) { _ in
            showAbout = true
        }
    }
    
    private var logoButton: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .overlay(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.1), Color.clear, Color.black.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 6)
            
            if isPlaying {
                PlayingIndicatorRing(color: selectedStation.color)
                    .padding(-4)
            }
            
            Image(selectedStation.logoName)
                .resizable()
                .scaledToFit()
                .frame(width: 85, height: 85)
                .clipShape(Circle())
                .opacity(isLoading ? 0.5 : 1.0)
            
            if isLoading {
                LoadingSpinner(color: selectedStation.color)
            }
            
            if !isPlaying && !isLoading {
                PlayOverlay(color: selectedStation.color)
                    .opacity(isHoveringLogo ? 1 : 0)
                    .animation(.easeOut(duration: 0.25), value: isHoveringLogo)
            }
            
            if isPlaying {
                VStack {
                    Spacer()
                    EqualizerView(color: selectedStation.color)
                        .padding(.bottom, 12)
                }
            }
        }
        .frame(width: 100, height: 100)
        .onHover { hovering in
            isHoveringLogo = hovering
        }
        .onTapGesture {
            audioPlayer.togglePlayPause()
        }
        .scaleEffect(isHoveringLogo ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHoveringLogo)
    }
    
    private func changeStation(to station: Station) {
        selectedStation = station
        audioPlayer.loadStation(station, autoPlay: true)
        nowPlayingService.startMonitoring(station: station)
    }
}

struct PlayOverlay: View {
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.4))
            
            Image(systemName: "play.fill")
                .font(.system(size: 40, weight: .semibold))
                .foregroundColor(color)
                .shadow(color: Color.black.opacity(0.4), radius: 4)
        }
    }
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
