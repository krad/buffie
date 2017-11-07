import Foundation
import AVFoundation

@available (macOS 10.11, *)
public class ScreenRecorder {
    
    /// The display we're capturing
    let display: Display
    
    /// The sample reader
    var reader: AVReaderProtocol
    
    /// Session control delegate
    private var controlDelegate: CameraControlDelegate?
    
    /// The capture session
    private var session: CaptureSessionProtocol?
    
    convenience public init(display: Display,
                reader: AVReaderProtocol,
                controlDelegate: CameraControlDelegate? = nil) throws
    {
        try self.init(display: display, audioDeviceID: nil, reader: reader, controlDelegate: controlDelegate)
    }
    
    required public init(display: Display,
                         audioDeviceID: String?,
                         reader: AVReaderProtocol,
                         controlDelegate: CameraControlDelegate? = nil,
                         capturesMouseClicks: Bool = true,
                         capturesCursor: Bool = true,
                         cropRect: CGRect? = nil) throws
    {
        self.display                    = display
        self.reader                     = reader
        self.controlDelegate            = controlDelegate
        let audioInput: AVCaptureInput? = try AVCaptureDeviceInput.input(for: audioDeviceID)
        
        let displayInput                 = display.input
        displayInput.capturesMouseClicks = capturesMouseClicks
        displayInput.capturesCursor      = capturesCursor
        if let crop = cropRect {
            displayInput.cropRect = crop
        }
        
        self.session = try CaptureSession(videoInput: display.input,
                                          audioInput: audioInput,
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
