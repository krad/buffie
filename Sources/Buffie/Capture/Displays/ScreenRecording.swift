import Foundation
import AVFoundation

@available (macOS 10.11, *)
public class ScreenRecorder {
    
    /// The display we're capturing
    let display: Display
    
    /// Should we show mouse clicks
    var showMouseClicks: Bool
    
    /// The sample reader
    var reader: CameraReaderProtocol
    
    /// Session control delegate
    private var controlDelegate: CameraControlDelegate?
    
    /// The capture session
    private var session: CameraSessionProtocol?
    
    init(display: Display,
         showMouseClicks: Bool = true,
         reader: CameraReaderProtocol,
         controlDelegate: CameraControlDelegate? = nil) throws {
        self.display            = display
        self.showMouseClicks    = showMouseClicks
        self.reader             = reader
        self.controlDelegate    = controlDelegate
        
        self.session = try CameraSession(videoInput: display.input,
                                         audioInput: nil,
                                         controlDelegate: self,
                                         cameraReader: reader)
    }
    
    func start() {
        self.session?.start()
    }
    
    func stop() {
        self.session?.stop()
    }
}

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
