//
//  BarcodeScannerView.swift
//  LiveLedger
//
//  LiveLedger - Barcode Scanner (Pro Feature)
//

import SwiftUI
import AVFoundation

// MARK: - Barcode Scanner View
struct BarcodeScannerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var scannedCode: String
    let onScan: (String) -> Void
    
    @State private var isScanning = true
    @State private var lastScannedCode: String = ""
    @State private var showFlash = false
    @State private var torchOn = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Camera view
                BarcodeCameraView(
                    scannedCode: $lastScannedCode,
                    isScanning: $isScanning,
                    torchOn: $torchOn
                )
                .ignoresSafeArea()
                
                // Overlay
                VStack {
                    Spacer()
                    
                    // Scanning frame
                    ZStack {
                        // Corner brackets
                        ScannerFrameView()
                            .frame(width: 280, height: 180)
                        
                        // Scanning line animation
                        if isScanning {
                            ScanningLineView()
                                .frame(width: 260, height: 2)
                        }
                    }
                    
                    Spacer()
                    
                    // Bottom controls
                    VStack(spacing: 16) {
                        // Scanned code display
                        if !lastScannedCode.isEmpty {
                            HStack {
                                Image(systemName: "barcode.viewfinder")
                                    .foregroundColor(.green)
                                Text(lastScannedCode)
                                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.7))
                            )
                            
                            Button {
                                scannedCode = lastScannedCode
                                onScan(lastScannedCode)
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Use This Code")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 40)
                        } else {
                            Text("Point camera at a barcode")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black.opacity(0.5))
                                )
                        }
                        
                        // Torch toggle
                        Button {
                            torchOn.toggle()
                        } label: {
                            Image(systemName: torchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(torchOn ? Color.yellow : Color.white.opacity(0.3))
                                )
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Scan Barcode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black.opacity(0.8), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Scanner Frame View
struct ScannerFrameView: View {
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let cornerLength: CGFloat = 30
            let lineWidth: CGFloat = 4
            
            ZStack {
                // Semi-transparent background with cutout
                Rectangle()
                    .fill(Color.black.opacity(0.5))
                    .mask(
                        Rectangle()
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .frame(width: width, height: height)
                                    .blendMode(.destinationOut)
                            )
                    )
                
                // Corner brackets
                Path { path in
                    // Top-left
                    path.move(to: CGPoint(x: 0, y: cornerLength))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: cornerLength, y: 0))
                    
                    // Top-right
                    path.move(to: CGPoint(x: width - cornerLength, y: 0))
                    path.addLine(to: CGPoint(x: width, y: 0))
                    path.addLine(to: CGPoint(x: width, y: cornerLength))
                    
                    // Bottom-right
                    path.move(to: CGPoint(x: width, y: height - cornerLength))
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.addLine(to: CGPoint(x: width - cornerLength, y: height))
                    
                    // Bottom-left
                    path.move(to: CGPoint(x: cornerLength, y: height))
                    path.addLine(to: CGPoint(x: 0, y: height))
                    path.addLine(to: CGPoint(x: 0, y: height - cornerLength))
                }
                .stroke(Color.green, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            }
        }
    }
}

// MARK: - Scanning Line Animation
struct ScanningLineView: View {
    @State private var offset: CGFloat = -80
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, .green, .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .offset(y: offset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
                ) {
                    offset = 80
                }
            }
    }
}

// MARK: - Camera View (UIKit Bridge)
struct BarcodeCameraView: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    @Binding var isScanning: Bool
    @Binding var torchOn: Bool
    
    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let controller = BarcodeScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {
        uiViewController.setTorch(on: torchOn)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, BarcodeScannerDelegate {
        let parent: BarcodeCameraView
        
        init(_ parent: BarcodeCameraView) {
            self.parent = parent
        }
        
        func didScanBarcode(_ code: String) {
            DispatchQueue.main.async {
                // Haptic feedback
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                
                self.parent.scannedCode = code
            }
        }
    }
}

// MARK: - Scanner Delegate Protocol
protocol BarcodeScannerDelegate: AnyObject {
    func didScanBarcode(_ code: String)
}

// MARK: - Barcode Scanner View Controller
class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: BarcodeScannerDelegate?
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var lastScannedCode: String = ""
    private var lastScanTime: Date = .distantPast
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }
    
    private func setupCamera() {
        let captureSession = AVCaptureSession()
        self.captureSession = captureSession
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("❌ No camera available")
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                
                // Support both standard barcodes AND QR codes
                metadataOutput.metadataObjectTypes = [
                    .ean8,
                    .ean13,
                    .upce,
                    .code39,
                    .code93,
                    .code128,
                    .pdf417,
                    .qr,
                    .aztec,
                    .dataMatrix
                ]
            }
            
            // Setup preview layer
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            self.previewLayer = previewLayer
            
        } catch {
            print("❌ Camera setup error: \(error)")
        }
    }
    
    func startScanning() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    func stopScanning() {
        captureSession?.stopRunning()
    }
    
    func setTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("❌ Torch error: \(error)")
        }
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // Debounce: prevent multiple rapid scans
        let now = Date()
        guard now.timeIntervalSince(lastScanTime) > 1.0 else { return }
        
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadataObject.stringValue else { return }
        
        // Don't report the same code twice in a row
        guard stringValue != lastScannedCode else { return }
        
        lastScannedCode = stringValue
        lastScanTime = now
        
        // Notify delegate
        delegate?.didScanBarcode(stringValue)
    }
}

// MARK: - Preview
#Preview {
    BarcodeScannerView(scannedCode: .constant("")) { code in
        print("Scanned: \(code)")
    }
}

