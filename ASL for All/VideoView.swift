//
//  VideoView.swift
//  ASL for All
//
//  Created by Thatcher Clough on 8/11/21.
//

import SwiftUI
import AVKit

struct VideoView: View {
    @ObservedObject var videoViewModel: VideoViewModel
    @Environment(\.colorScheme) var colorScheme
    
    init(urls :[URL], words: [String], wrappedHStackWidth: CGFloat) {
        videoViewModel = VideoViewModel(urls: urls, words: words, wrappedHStackWidth: wrappedHStackWidth)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                PlayerContainer(videoViewModel.player)
                    .aspectRatio(0.7777777777777778, contentMode: .fit)
                    .cornerRadius(30)
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 0)
                    .frame(height: geometry.size.height * 0.55)
                
                ZStack {
                    VStack {
                        GeometryReader { geometry in
                            captionsView()
                                .onAppear() {
                                    videoViewModel.adjustWrappedHStackFontSize(height: geometry.size.height)
                                }
                                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        }
                        
                        if videoViewModel.showHint {
                            ZStack {
                                HStack {
                                    Text("You can click on each word above to play the sign for that word!")
                                        .font(.system(size: 15, weight: .regular))
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(nil)
                                        .padding(10)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    Button {
                                        videoViewModel.showHint = false
                                    } label: {
                                        Image(systemName: "xmark")
                                    }
                                    .buttonStyle(CircularButtonStyle(size: 10, height: 20))
                                    .padding(.trailing, 10)
                                }
                            }
                            .background(colorScheme == .dark ? Color.white.opacity(0.15) : Color.white)
                            .cornerRadius(10)
                            .frame(maxWidth: videoViewModel.wrappedHStackWidth)
                            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 0)
                            .transition(defaultTransition)
                        }
                        
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: geometry.size.height - (geometry.size.height * 0.55 + geometry.size.height * 0.45 * 0.6) + 25)
                    }
                    
                    HStack {
                        Button {
                            videoViewModel.showSpeeds = false
                            videoViewModel.playVideoOfWord(index: 0)
                        } label: {
                            Image(systemName: "backward.fill")
                        }
                        .buttonStyle(videoViewModel.controlButtonStyle)
                        
                        Button {
                            videoViewModel.showSpeeds = false
                            videoViewModel.paused.toggle()
                            if videoViewModel.paused {
                                videoViewModel.player.avQueuePlayer.pause()
                            } else {
                                videoViewModel.player.avQueuePlayer.play()
                                videoViewModel.player.avQueuePlayer.rate = Float(videoViewModel.speed)
                            }
                        } label: {
                            if videoViewModel.paused {
                                Image(systemName: "play.fill")
                            } else {
                                Image(systemName: "pause.fill")
                            }
                        }
                        .buttonStyle(ControlButtonStyle(font: .system(size: 23, weight: .semibold), height: 35, width: 35, padding: 10))
                        
                        VStack {
                            if !videoViewModel.showSpeeds {
                                Circle()
                                    .frame(width: 35, height: 35)
                                    .padding(10)
                                    .foregroundColor(.clear)
                                
                                Button {
                                    videoViewModel.showSpeeds = true
                                } label: {
                                    Image(systemName: "hare.fill")
                                }
                                .buttonStyle(videoViewModel.controlButtonStyle)
                                
                                Circle()
                                    .frame(width: 35, height: 35)
                                    .padding(10)
                                    .foregroundColor(.clear)
                            } else {
                                Button {
                                    videoViewModel.showSpeeds = false
                                    videoViewModel.speed = 0.5
                                    if !videoViewModel.paused {
                                        videoViewModel.player.avQueuePlayer.rate = Float(videoViewModel.speed)
                                    }
                                } label: {
                                    HStack (alignment: .center, spacing: 1) {
                                        Text("x")
                                            .font(.system(size: 15, weight: .semibold))
                                        Text("\u{00BD}")
                                            .font(.system(size: 25, weight: .semibold))
                                    }
                                }
                                .buttonStyle(videoViewModel.controlButtonStyle)
                                
                                Button {
                                    videoViewModel.showSpeeds = false
                                    videoViewModel.speed = 1.1
                                    if !videoViewModel.paused {
                                        videoViewModel.player.avQueuePlayer.rate = Float(videoViewModel.speed)
                                    }
                                } label: {
                                    HStack (alignment: .center, spacing: 1) {
                                        Text("x")
                                            .font(.system(size: 15, weight: .semibold))
                                        Text("1")
                                            .font(.system(size: 20, weight: .semibold))
                                    }
                                }
                                .buttonStyle(videoViewModel.controlButtonStyle)
                                
                                Button {
                                    videoViewModel.showSpeeds = false
                                    videoViewModel.speed = 2.0
                                    if !videoViewModel.paused {
                                        videoViewModel.player.avQueuePlayer.rate = Float(videoViewModel.speed)
                                    }
                                } label: {
                                    HStack (alignment: .center, spacing: 1) {
                                        Text("x")
                                            .font(.system(size: 15, weight: .semibold))
                                        Text("2")
                                            .font(.system(size: 20, weight: .semibold))
                                    }
                                }
                                .buttonStyle(videoViewModel.controlButtonStyle)
                            }
                        }
                    }
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.45 * 0.6)
                }
            }
            .onAppear() {
                if UserDefaults.standard.object(forKey: "showHint") == nil {
                    videoViewModel.showHint = true
                }
                videoViewModel.setup()
            }
        }
    }
    
    @ViewBuilder
    func captionsView() -> some View {
        WrappedHStack(width: videoViewModel.wrappedHStackWidth, spacing: videoViewModel.wrappedHStackSpacing) {
            ForEach(0..<videoViewModel.words.count, id: \.self) { index in
                Button {
                    videoViewModel.showSpeeds = false
                    videoViewModel.paused = false
                    videoViewModel.player.avQueuePlayer.play()
                    videoViewModel.player.avQueuePlayer.rate = Float(videoViewModel.speed)
                    videoViewModel.playVideoOfWord(index: index)
                } label: {
                    Text(videoViewModel.words[index])
                        .fixedSize(horizontal: false, vertical: true)
                }
                .buttonStyle(CaptionsButtonStyle(font: .system(size: videoViewModel.fontSize, weight: .semibold), verticalPadding: 3, horizontalPadding: 5, cornerRadius: 10, highlighted: videoViewModel.indexOfCurrentPlayingWord == index))
                .animation(Animation.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 1))
            }
        }
    }
}

class VideoViewModel: ObservableObject {
    let controlButtonStyle: ControlButtonStyle = ControlButtonStyle(font: .system(size: 20, weight: .semibold), height: 35, width: 35, padding: 10)
    
    var words: [String]
    var player: ActualPlayer
    var urls: [URL] = []
    var wrappedHStackWidth: CGFloat
    let wrappedHStackSpacing = 5.0
    
    @Published var indexOfCurrentPlayingWord: Int = 0
    @Published var fontSize: CGFloat = 25
    @Published var showHint = UserDefaults.standard.bool(forKey: "showHint") {
        didSet {
            UserDefaults.standard.set(showHint, forKey: "showHint")
        }
    }
    @Published var paused: Bool = false
    @Published var speed: Double = 1.1
    @Published var showSpeeds: Bool = false
    
    init (urls: [URL], words: [String], wrappedHStackWidth: CGFloat) {
        self.words = words
        self.urls = urls
        if urls.count > 0 {
            player = ActualPlayer(initialItem: AVPlayerItem(url: urls[0]))
            player.avQueuePlayer.insert(urls.count <= 1 ? AVPlayerItem(url: urls[0]) : AVPlayerItem(url: urls[1]), after: nil)
        } else {
            player = ActualPlayer(initialItem: AVPlayerItem(asset: AVAsset()))
        }
        
        self.wrappedHStackWidth = wrappedHStackWidth
    }
    
    func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc func playerDidFinishPlaying() {
        player.avQueuePlayer.seek(to: .zero)
        DispatchQueue.main.async {
            self.indexOfCurrentPlayingWord = self.getIndexOfNextWord()
            self.queueNextVideo()
        }
    }
    
    func queueNextVideo() {
        let indexOfNextWord = getIndexOfNextWord()
        if indexOfNextWord >= 0 && indexOfNextWord < urls.count {
            player.avQueuePlayer.insert(AVPlayerItem(url: urls[indexOfNextWord]), after: nil)
        }
    }
    
    func getIndexOfNextWord() -> Int {
        return self.indexOfCurrentPlayingWord + 1 >= self.words.count ? 0 : self.indexOfCurrentPlayingWord + 1
    }
    
    func adjustWrappedHStackFontSize(height: CGFloat) {
        var fontSize: CGFloat = 25.0
        while !words.isEmpty && getWrappedHStackHeight(fontSize: fontSize) > height {
            fontSize -= 1
        }
        
        DispatchQueue.main.async {
            self.fontSize = fontSize
        }
    }
    
    func getWrappedHStackHeight(fontSize: CGFloat) -> CGFloat {
        let view = WrappedHStack(width: wrappedHStackWidth, spacing: wrappedHStackSpacing) {
            ForEach(0..<words.count, id: \.self) { index in
                Button {} label: {
                    Text(self.words[index])
                        .fixedSize()
                }
                .buttonStyle(CaptionsButtonStyle(font: .system(size: fontSize, weight: .semibold), verticalPadding: 3, horizontalPadding: 5, cornerRadius: 10, highlighted: false))
                .animation(Animation.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 1))
            }
        }
        return view.getSize().height
    }
    
    func playVideoOfWord(index: Int) {
        if index == indexOfCurrentPlayingWord {
            player.avQueuePlayer.seek(to: .zero)
        } else {
            if player.avQueuePlayer.items().count > 1 {
                for index in 1..<player.avQueuePlayer.items().count {
                    player.avQueuePlayer.remove(player.avQueuePlayer.items()[index])
                }
            }
            
            player.avQueuePlayer.insert(AVPlayerItem(url: urls[index]), after: nil)
            indexOfCurrentPlayingWord = index
            player.avQueuePlayer.advanceToNextItem()
            player.avQueuePlayer.seek(to: .zero)
            queueNextVideo()
        }
    }
}

struct PlayerContainer: UIViewRepresentable {
    var player: ActualPlayer
    
    init(_ player: ActualPlayer) {
        self.player = player
    }
    
    func makeUIView(context: Context) -> UIView {
        return player
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

class ActualPlayer: UIView {
    var avQueuePlayer: AVQueuePlayer
    var playerLayer: AVPlayerLayer = AVPlayerLayer()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(initialItem: AVPlayerItem) {
        
        avQueuePlayer = AVQueuePlayer(playerItem: initialItem)
        avQueuePlayer.allowsExternalPlayback = false
        
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        playerLayer.player = avQueuePlayer
        layer.addSublayer(playerLayer)
        
        layoutSubviews()
        
        avQueuePlayer.play()
        avQueuePlayer.rate = 1.1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = bounds
    }
}

struct CaptionsButtonStyle: ButtonStyle {
    let font: Font
    let verticalPadding: CGFloat
    let horizontalPadding: CGFloat
    let cornerRadius: CGFloat
    let highlighted: Bool
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(font)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .background(Color.accentColor.opacity(highlighted ? 0.4 : 0))
            .foregroundColor(Color(UIColor.label))
            .cornerRadius(cornerRadius)
            .scaleEffect(highlighted ? 1.1 : 1.0)
            .shadow(color: .accentColor.opacity(highlighted ? 0.4 : 0), radius: 10, y: 0)
            .lineLimit(nil)
    }
}

struct ControlButtonStyle: ButtonStyle {
    let font: Font?
    let height: CGFloat
    let width: CGFloat
    let padding: CGFloat
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(font)
            .frame(width: width, height: height)
            .padding(padding)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(((2 * padding) + height) / 2)
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
            .shadow(color: .accentColor.opacity(0.4), radius: 10, y: 0)
    }
}
