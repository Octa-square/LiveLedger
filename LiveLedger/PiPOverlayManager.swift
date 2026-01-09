//
//  PiPOverlayManager.swift
//  LiveLedger
//
//  Picture-in-Picture overlay that stays on top of other apps
//

import SwiftUI
import AVKit
import Combine

// MARK: - PiP Overlay Manager
class PiPOverlayManager: NSObject, ObservableObject {
    static let shared = PiPOverlayManager()
    
    @Published var isPiPActive: Bool = false
    @Published var isPiPSupported: Bool = false
    
    private var pipController: AVPictureInPictureController?
    private var pipVideoCallViewController: AVPictureInPictureVideoCallViewController?
    private var playerLayer: AVPlayerLayer?
    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    
    // Content to display
    private var contentView: UIView?
    private var displayLink: CADisplayLink?
    private var sampleBufferDisplayLayer: AVSampleBufferDisplayLayer?
    
    // Callbacks
    var onPiPTapped: (() -> Void)?
    var onPiPClosed: (() -> Void)?
    
    private override init() {
        super.init()
        setupPiP()
    }
    
    // MARK: - Setup
    private func setupPiP() {
        // Check if PiP is supported
        // Note: PiP requires a REAL device - doesn't work on Simulator
        #if targetEnvironment(simulator)
        isPiPSupported = false
        print("ℹ️ PiP not available on Simulator - test on a real device")
        #else
        isPiPSupported = AVPictureInPictureController.isPictureInPictureSupported()
        
        if !isPiPSupported {
            print("⚠️ PiP not supported - requires iOS 14+ and iPhone 8 or newer")
        }
        
        guard isPiPSupported else { return }
        
        // Configure audio session for PiP
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ Failed to set audio session: \(error)")
        }
        
        // Create a silent video for PiP (required for PiP to work)
        setupSilentVideoPlayer()
        #endif
    }
    
    private func setupSilentVideoPlayer() {
        // Create a tiny silent video asset in memory
        guard let videoURL = createSilentVideo() else {
            print("❌ Failed to create silent video")
            return
        }
        
        let asset = AVURLAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        
        player = AVQueuePlayer(playerItem: playerItem)
        player?.isMuted = true
        player?.allowsExternalPlayback = false
        
        // Loop the video indefinitely
        if let player = player {
            looper = AVPlayerLooper(player: player, templateItem: playerItem)
        }
        
        // Create player layer
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        playerLayer?.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        
        // Create PiP controller
        if let playerLayer = playerLayer {
            pipController = AVPictureInPictureController(playerLayer: playerLayer)
            pipController?.delegate = self
            pipController?.canStartPictureInPictureAutomaticallyFromInline = true
        }
    }
    
    private func createSilentVideo() -> URL? {
        // Create a 1-second silent video with a green frame
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let videoURL = documentsPath.appendingPathComponent("pip_placeholder.mp4")
        
        // If video already exists, return it
        if FileManager.default.fileExists(atPath: videoURL.path) {
            return videoURL
        }
        
        // Create video settings
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: 320,
            AVVideoHeightKey: 320
        ]
        
        guard let videoWriter = try? AVAssetWriter(outputURL: videoURL, fileType: .mp4) else {
            return nil
        }
        
        let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: videoInput,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
                kCVPixelBufferWidthKey as String: 320,
                kCVPixelBufferHeightKey as String: 320
            ]
        )
        
        videoWriter.add(videoInput)
        videoWriter.startWriting()
        videoWriter.startSession(atSourceTime: .zero)
        
        // Create a green frame
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(
            kCFAllocatorDefault,
            320,
            320,
            kCVPixelFormatType_32ARGB,
            nil,
            &pixelBuffer
        )
        
        if let buffer = pixelBuffer {
            CVPixelBufferLockBaseAddress(buffer, [])
            let baseAddress = CVPixelBufferGetBaseAddress(buffer)
            let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
            let width = CVPixelBufferGetWidth(buffer)
            let height = CVPixelBufferGetHeight(buffer)
            
            // Fill with LiveLedger green color (0x10B981)
            for y in 0..<height {
                for x in 0..<width {
                    let offset = y * bytesPerRow + x * 4
                    baseAddress?.storeBytes(of: 255, toByteOffset: offset, as: UInt8.self)     // A
                    baseAddress?.storeBytes(of: 16, toByteOffset: offset + 1, as: UInt8.self)  // R
                    baseAddress?.storeBytes(of: 185, toByteOffset: offset + 2, as: UInt8.self) // G
                    baseAddress?.storeBytes(of: 129, toByteOffset: offset + 3, as: UInt8.self) // B
                }
            }
            
            CVPixelBufferUnlockBaseAddress(buffer, [])
            
            // Write 30 frames for 1 second of video
            let frameDuration = CMTime(value: 1, timescale: 30)
            for i in 0..<30 {
                while !videoInput.isReadyForMoreMediaData {
                    Thread.sleep(forTimeInterval: 0.01)
                }
                let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(i))
                adaptor.append(buffer, withPresentationTime: presentationTime)
            }
        }
        
        videoInput.markAsFinished()
        
        let semaphore = DispatchSemaphore(value: 0)
        videoWriter.finishWriting {
            semaphore.signal()
        }
        semaphore.wait()
        
        return videoURL
    }
    
    // MARK: - Public Methods
    func startPiP() {
        guard isPiPSupported else {
            print("⚠️ PiP not supported")
            return
        }
        
        guard let controller = pipController else {
            print("❌ PiP controller not initialized")
            return
        }
        
        player?.play()
        
        if controller.isPictureInPicturePossible {
            controller.startPictureInPicture()
        } else {
            print("⚠️ PiP not currently possible")
        }
    }
    
    func stopPiP() {
        pipController?.stopPictureInPicture()
        player?.pause()
        isPiPActive = false
    }
    
    func togglePiP() {
        if isPiPActive {
            stopPiP()
        } else {
            startPiP()
        }
    }
}

// MARK: - PiP Delegate
extension PiPOverlayManager: AVPictureInPictureControllerDelegate {
    
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("🎬 PiP will start")
    }
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("✅ PiP started")
        DispatchQueue.main.async {
            self.isPiPActive = true
        }
    }
    
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("🛑 PiP will stop")
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("⏹ PiP stopped")
        DispatchQueue.main.async {
            self.isPiPActive = false
            self.onPiPClosed?()
        }
    }
    
    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        failedToStartPictureInPictureWithError error: Error
    ) {
        print("❌ PiP failed to start: \(error.localizedDescription)")
    }
    
    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        // User tapped PiP to return to app
        print("👆 User tapped PiP - returning to app")
        onPiPTapped?()
        completionHandler(true)
    }
}

// MARK: - PiP Overlay View (shows in-app overlay with PiP button)
struct PiPReadyOverlayView: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @StateObject private var overlayManager = TikTokLiveOverlayManager.shared
    @StateObject private var pipManager = PiPOverlayManager.shared
    
    @State private var selectedProduct: Product?
    @State private var showOrderPopup = false
    @State private var buyerName = ""
    @State private var orderQuantity = 1
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        if overlayManager.isOverlayVisible {
            GeometryReader { geometry in
                ZStack {
                    overlayContent
                        .position(
                            x: overlayManager.overlayPosition.x + dragOffset.width,
                            y: overlayManager.overlayPosition.y + dragOffset.height
                        )
                        .gesture(DragGesture()
                            .onChanged { dragOffset = $0.translation }
                            .onEnded { value in
                                overlayManager.overlayPosition.x += value.translation.width
                                overlayManager.overlayPosition.y += value.translation.height
                                dragOffset = .zero
                                overlayManager.savePreferences()
                            }
                        )
                    
                    if showOrderPopup, let product = selectedProduct {
                        orderEntryPopup(product: product)
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
    
    private var overlayContent: some View {
        VStack(spacing: 0) {
            // Header with PiP button
            HStack {
                Text("Quick Add")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // PiP button (Float on top of other apps)
                // Only shows on real devices that support PiP
                #if !targetEnvironment(simulator)
                if pipManager.isPiPSupported {
                    Button {
                        pipManager.startPiP()
                    } label: {
                        Image(systemName: "pip.enter")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.trailing, 8)
                }
                #endif
                
                Button { overlayManager.hideOverlay() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.8))
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.fixed(55), spacing: 6),
                    GridItem(.fixed(55), spacing: 6),
                    GridItem(.fixed(55), spacing: 6)
                ], spacing: 6) {
                    ForEach(viewModel.products.filter { !$0.isEmpty }) { product in
                        ProductOverlayCard(product: product) {
                            selectedProduct = product
                            buyerName = ""
                            orderQuantity = 1
                            showOrderPopup = true
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }
                }
                .padding(6)
            }
            .frame(maxHeight: 130)
            
            // Footer with PiP hint
            HStack {
                Text("Orders: \(viewModel.orderCount)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                
                #if !targetEnvironment(simulator)
                if pipManager.isPiPSupported {
                    Image(systemName: "pip")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.5))
                    Text("Float")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.5))
                }
                #endif
                
                Spacer()
                
                Text("$\(viewModel.totalRevenue, specifier: "%.2f")")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.green)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.8))
        }
        .frame(width: overlayManager.overlaySize.width, height: overlayManager.overlaySize.height)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(overlayManager.overlayOpacity)))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.green.opacity(0.5), lineWidth: 2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.5), radius: 10)
    }
    
    private func orderEntryPopup(product: Product) -> some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea().onTapGesture { showOrderPopup = false }
            
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    if let imageData = product.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage).resizable().scaledToFill()
                            .frame(width: 50, height: 50).clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        RoundedRectangle(cornerRadius: 8).fill(Color.green.opacity(0.3))
                            .frame(width: 50, height: 50)
                            .overlay(Text(String(product.name.prefix(1))).font(.system(size: 20, weight: .bold)).foregroundColor(.green))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(product.name).font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                        Text("$\(product.price, specifier: "%.2f")").font(.system(size: 14, weight: .semibold)).foregroundColor(.green)
                        Text("Stock: \(product.stock)").font(.system(size: 12)).foregroundColor(.gray)
                    }
                    Spacer()
                }
                
                Divider().background(Color.gray.opacity(0.3))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Buyer Name (Optional)").font(.system(size: 12, weight: .medium)).foregroundColor(.gray)
                    TextField("Enter buyer name", text: $buyerName)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(10).background(Color.white.opacity(0.1)).cornerRadius(8).foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quantity").font(.system(size: 12, weight: .medium)).foregroundColor(.gray)
                    HStack {
                        Button { if orderQuantity > 1 { orderQuantity -= 1 } } label: {
                            Image(systemName: "minus.circle.fill").font(.system(size: 28)).foregroundColor(.red)
                        }
                        Text("\(orderQuantity)").font(.system(size: 24, weight: .bold)).foregroundColor(.white).frame(minWidth: 50)
                        Button { if orderQuantity < product.stock { orderQuantity += 1 } } label: {
                            Image(systemName: "plus.circle.fill").font(.system(size: 28)).foregroundColor(.green)
                        }
                    }.frame(maxWidth: .infinity)
                }
                
                HStack {
                    Text("Total:").font(.system(size: 14)).foregroundColor(.gray)
                    Spacer()
                    Text("$\(product.price * Double(orderQuantity), specifier: "%.2f")").font(.system(size: 18, weight: .bold)).foregroundColor(.green)
                }
                
                HStack(spacing: 12) {
                    Button { showOrderPopup = false } label: {
                        Text("Cancel").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 12).background(Color.gray.opacity(0.3)).cornerRadius(8)
                    }
                    Button { addOrder(product: product) } label: {
                        Text("Add Order").font(.system(size: 14, weight: .bold)).foregroundColor(.black)
                            .frame(maxWidth: .infinity).padding(.vertical, 12).background(Color.green).cornerRadius(8)
                    }
                }
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(white: 0.15)))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.green.opacity(0.3), lineWidth: 1))
            .frame(width: 300)
            .shadow(color: .black.opacity(0.5), radius: 20)
        }
    }
    
    private func addOrder(product: Product) {
        viewModel.addOrder(product: product, quantity: orderQuantity, buyerName: buyerName.isEmpty ? nil : buyerName)
        SoundManager.shared.playOrderAddedSound()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        showOrderPopup = false
        selectedProduct = nil
    }
}
