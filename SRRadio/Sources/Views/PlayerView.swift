import SwiftUI

struct DynamicBackground: View {
    let color: Color
    
    var body: some View {
        ZStack {
#if os(macOS)
            VisualEffectView(material: .popover, blendingMode: .behindWindow, state: .active)
#else
            VisualEffectView()
#endif
            
            Color.black.opacity(0.55) // Ensures a consistently dark backdrop even in macOS Light Mode
            
            color
                .opacity(0.4)
                .blendMode(.overlay)
            
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            RadialGradient(
                colors: [color.opacity(0.35), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 350
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
            DynamicBackground(color: selectedStation.color)
            
            VStack(spacing: 0) {
                // Top Bar
                ZStack {
                    HStack {
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
                    
                    StationSelector(
                        selectedStation: $selectedStation,
                        isExpanded: $showStationSelector,
                        stations: Station.all
                    ) { newStation in
                        changeStation(to: newStation)
                    }
                }
                .padding(.horizontal, 22)
#if os(macOS)
                .padding(.top, 36) // extra padding to clear macOS traffic lights
#else
                .padding(.top, 16)
#endif
                .zIndex(2)
                
                Spacer()
                
                // Artwork
                logoButton
                    .padding(.vertical, 16)
                    .zIndex(1)
                
                // Track Info
                VStack(spacing: 8) {
                    Text(selectedStation.name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.3), radius: 2, y: 1)
                    
                    NowPlayingView(
                        data: nowPlayingService.currentData,
                        isLoading: nowPlayingService.isLoading,
                        stationColor: selectedStation.color
                    )
                }
                .padding(.horizontal, 20)
                .frame(height: 70)
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
                    .padding(.bottom, 6)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .zIndex(1)
            }
#if os(macOS)
            .frame(width: 320, height: 480)
#else
            .frame(maxWidth: .infinity, maxHeight: .infinity)
#endif
            
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
                .zIndex(3)
            }
        }
#if os(macOS)
        .frame(width: 320, height: 480)
#else
        .frame(maxWidth: .infinity, maxHeight: .infinity)
#endif
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
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.05))
#if os(macOS)
                .background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow, state: .active).clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous)))
#else
                .background(VisualEffectView().clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous)))
#endif
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                )
                .shadow(color: selectedStation.color.opacity(0.4), radius: 24, x: 0, y: 10)
                .shadow(color: Color.black.opacity(0.5), radius: 12, x: 0, y: 6)
            
            Image(selectedStation.logoName)
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
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
        .frame(width: 200, height: 200)
        .onHover { hovering in
            isHoveringLogo = hovering
        }
        .onTapGesture {
            audioPlayer.togglePlayPause()
        }
        .scaleEffect(isHoveringLogo ? 1.02 : (isPlaying ? 1.0 : 0.98))
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isHoveringLogo)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isPlaying)
    }
    
    private func changeStation(to station: Station) {
        selectedStation = station
        audioPlayer.loadStation(station, autoPlay: true)
        nowPlayingService.startMonitoring(station: station)
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
