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
    
    /// Which camera to use front/back
    public var position: CameraPosition
    
    /// Used to handle control events with the camera.  Like when it starts, stops, or is interuppted
    public var controlDelegate: CameraControlDelegate?
    
    /// Used to obtain and classified samples streamed from the camera (audio or video samples)
    internal var cameraReader: CameraReaderProtocol

    /// The actual camera session object.  Used for stubbing
    internal var cameraSession: CameraSessionProtocol?
    
    init(_ position: CameraPosition = .back, reader: CameraReaderProtocol = CameraReader(), controlDelegate: CameraControlDelegate? = nil) throws {
        self.position        = position
        self.controlDelegate = controlDelegate
        self.cameraReader    = reader
        self.cameraSession = try CameraSession(position.osPosition, controlDelegate: self, cameraReader: self.cameraReader)
    }
    
    /// Start the camera
    func start() {
        self.cameraSession?.start()
    }
    
    /// Stop the camera
    func stop() {
        self.cameraSession?.stop()
    }
    
}

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
