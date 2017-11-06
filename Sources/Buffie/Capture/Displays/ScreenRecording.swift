import Foundation
import AVFoundation

@available (macOS 10.11, *)
public class ScreenRecorder {
    
    /// The display we're capturing
    let display: Display
    
    /// The sample reader
    var reader: CameraReaderProtocol
    
    /// Session control delegate
    private var controlDelegate: CameraControlDelegate?
    
    /// The capture session
    private var session: CameraSessionProtocol?
    
    public init(display: Display,
                reader: CameraReaderProtocol,
                controlDelegate: CameraControlDelegate? = nil) throws
    {
        self.display            = display
        self.reader             = reader
        self.controlDelegate    = controlDelegate
        
        self.session = try CameraSession(videoInput: display.input,
                                         audioInput: nil,
                                         controlDelegate: self,
                                         cameraReader: reader)
    }
    
    public func start() {
        self.session?.start()
    }
    
    public func stop() {
        self.session?.stop()
    }
}

@available (macOS 10.11, *)
extension ScreenRecorder: CaptureDevice { }

@available (macOS 10.11, *)
extension ScreenRecorder: CameraControlDelegate {
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
