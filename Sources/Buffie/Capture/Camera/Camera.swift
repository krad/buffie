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
public enum CaptureDeviceError: Error {
    case deviceNotFound(deviceID: String)
    case noDeviceAvailable(type: AVMediaType)
    case noDevicesAvailable
}

/// Protocol used to handle changes to the camera's state
public protocol CameraControlDelegate {
    func cameraStarted()
    func cameraStopped()
    func cameraInteruppted()
}

public protocol CaptureDevice {
    func start()
    func stop()
}

public class Camera {
    
    /// Which camera to use front/back
    public var position: CameraPosition?
    
    /// Used to handle control events with the camera.  Like when it starts, stops, or is interuppted
    public var controlDelegate: CameraControlDelegate?
    
    /// Used to obtain and classified samples streamed from the camera (audio or video samples)
    internal var cameraReader: AVReaderProtocol

    /// The actual camera session object.  Used for stubbing
    internal var cameraSession: CaptureSessionProtocol?
    
    public init(_ position: CameraPosition = .back,
                reader: AVReaderProtocol = AVReader(),
                controlDelegate: CameraControlDelegate? = nil) throws {
        self.position        = position
        self.controlDelegate = controlDelegate
        self.cameraReader    = reader
        self.cameraSession = try CaptureSession(position.osPosition,
                                                controlDelegate: self,
                                                cameraReader: self.cameraReader)
    }
    
    
    public init(videoDeviceID: String,
                audioDeviceID: String,
                reader: AVReaderProtocol = AVReader(),
                controlDelegate: CameraControlDelegate? = nil) throws {
        self.controlDelegate = controlDelegate
        self.cameraReader    = reader
        self.cameraSession   = try CaptureSession(videoDeviceID: videoDeviceID,
                                                 audioDeviceID: audioDeviceID,
                                                 controlDelegate: self,
                                                 cameraReader: self.cameraReader)
    }
    
    public init(videoDeviceID: String?,
                audioDeviceID: String?,
                reader: AVReaderProtocol = AVReader(),
                controlDelegate: CameraControlDelegate? = nil) throws {
        self.controlDelegate = controlDelegate
        self.cameraReader    = reader
        self.cameraSession   = try CaptureSession(videoDeviceID: videoDeviceID,
                                                  audioDeviceID: audioDeviceID,
                                                  controlDelegate: self,
                                                  cameraReader: self.cameraReader)
    }

    
    /// Start the camera
    public func start() {
        self.cameraSession?.start()
    }
    
    public func start(onComplete: ((AVCaptureSession) -> Void)? = nil) {
        self.cameraSession?.start(onComplete: onComplete)
    }
    
    /// Stop the camera
    public func stop() {
        self.cameraSession?.stop()
    }
    
    public func flip() {
        guard let session = cameraSession else { return }
        if self.position == .front {
            if session.changeToCamera(position: .back) {
                self.position = .back
            }
        } else {
            if session.changeToCamera(position: .front) {
                self.position = .front
            }
        }
    }
    
}

extension Camera: CaptureDevice { }

extension Camera: CameraControlDelegate {
    public func cameraStarted() {
        self.controlDelegate?.cameraStarted()
    }
    
    public func cameraStopped() {
        self.controlDelegate?.cameraStopped()
    }
    
    public func cameraInteruppted() {
        self.controlDelegate?.cameraInteruppted()
    }
}
