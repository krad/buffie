import Foundation
import AVKit


/// Enum representing the position of the camera
public enum CameraPosition {
    case front
    case back
    
    fileprivate var osPosition: AVCaptureDevice.Position {
        switch self {
        case .front: return AVCaptureDevice.Position.front
        case .back: return AVCaptureDevice.Position.back
        }
    }
}


/// Enum representing things that can go wrong with the camera
///
/// - noCameraFound: Thrown when we can't find a device suitable for capturing video
public enum CameraError: Error {
    case noCameraFound
}

/// Protocol used to handle changes to the camera's state
public protocol CameraControlDelegate {
    func cameraStarted()
    func cameraStopped()
    func cameraInteruppted()
}

public class Camera {
    
    public var position: CameraPosition
    public var controlDelegate: CameraControlDelegate?
    
    @objc private var session: AVCaptureSession
    var sessionObserver: NSKeyValueObservation?

    private var device: AVCaptureDevice
    private var input: AVCaptureDeviceInput
    
    private var videoOutput: AVCaptureVideoDataOutput
    private let videoQueue = DispatchQueue(label: "videoQ")

    private var audioOutput: AVCaptureAudioDataOutput
    private let audioQueue = DispatchQueue(label: "audioQ")
    
    init(_ position: CameraPosition = .back, controlDelegate: CameraControlDelegate? = nil) throws {
        self.position        = position
        self.controlDelegate = controlDelegate
        
        self.session         = AVCaptureSession()
        self.device          = try AVCaptureDevice.firstDevice(for: AVMediaType.video, in: position.osPosition)
        self.input           = try AVCaptureDeviceInput(device: self.device)
        
        self.videoOutput     = AVCaptureVideoDataOutput()
        self.audioOutput     = AVCaptureAudioDataOutput()
        
        self.session.addInput(self.input)
        self.session.addOutput(self.videoOutput)
        self.session.addOutput(self.audioOutput)

        self.setupObservers()
    }
    
    private func setupObservers() {
        self.sessionObserver = self.session.observe(\.isRunning) { session, _ in
            if session.isRunning {
                self.controlDelegate?.cameraStarted()
            } else {
                self.controlDelegate?.cameraStopped()
            }
        }
    }
    
    /// Start the camera
    func start() {
        self.session.startRunning()
    }
    
    /// Stop the camera
    func stop() {
        self.session.stopRunning()
    }
    
    
    deinit {
        self.sessionObserver?.invalidate()
    }
    
}


extension AVCaptureDevice {
    
    static func firstDevice(for mediaType: AVMediaType, in position: AVCaptureDevice.Position) throws -> AVCaptureDevice {
        let devices = AVCaptureDevice.devices(for: AVMediaType.video).filter { $0.position != position }
        if let device = devices.first {
            return device
        } else {
            throw CameraError.noCameraFound
        }
    }
    
}
