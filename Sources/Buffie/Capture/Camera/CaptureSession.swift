import Foundation
import AVKit

internal protocol CaptureSessionProtocol {
    var videoOutput: AVCaptureVideoDataOutput? { get }
    var audioOutput: AVCaptureAudioDataOutput? { get }

    func start()
    func start(onComplete: ((AVCaptureSession) -> Void)?)
    
    func stop()
}

internal class CaptureSession: CaptureSessionProtocol {
    
    private var controlDelegate: CameraControlDelegate
    
    @objc private var session: AVCaptureSession
    var sessionObserver: NSKeyValueObservation?
    
    private var videoInput: AVCaptureInput?
    internal var videoOutput: AVCaptureVideoDataOutput?
    private let videoQueue = DispatchQueue(label: "videoQ")
    
    private var audioInput: AVCaptureInput?
    internal var audioOutput: AVCaptureAudioDataOutput?
    private let audioQueue = DispatchQueue(label: "audioQ")
    
    required init(videoInput: AVCaptureInput? = nil,
                  audioInput: AVCaptureInput? = nil,
                  controlDelegate: CameraControlDelegate,
                  cameraReader: AVReaderProtocol) throws
    {
        self.controlDelegate       = controlDelegate
        self.session               = AVCaptureSession()
        
        if let vInput = videoInput {
            self.videoInput     = vInput
            self.videoOutput    = AVCaptureVideoDataOutput()
            
            // Add the video i/o to the session
            self.session.addInput(self.videoInput!)
            self.session.addOutput(self.videoOutput!)
            self.videoOutput!.setSampleBufferDelegate(cameraReader.videoReader, queue: videoQueue)
            
        }
        
        if let aInput = audioInput {
            self.audioInput  = aInput
            self.audioOutput = AVCaptureAudioDataOutput()
            
            #if os(macOS)
            self.audioOutput?.audioSettings = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMIsNonInterleaved: false,
            ]
            #endif

            // Add the audio i/o to the session
            self.session.addInput(self.audioInput!)
            self.session.addOutput(self.audioOutput!)
            self.audioOutput!.setSampleBufferDelegate(cameraReader.audioReader, queue: audioQueue)
        }
        
        self.setupObservers()
    }
    
    convenience init(videoDeviceID: String?,
                     audioDeviceID: String?,
                     controlDelegate: CameraControlDelegate,
                     cameraReader: AVReaderProtocol) throws
    {
        var videoInput: AVCaptureInput? = nil
        var audioInput: AVCaptureInput? = nil
        
        // Attempt to configure the video device
        videoInput = try AVCaptureDeviceInput.input(for: videoDeviceID)
        
        // Attempt to configure the video device
        audioInput = try AVCaptureDeviceInput.input(for: audioDeviceID)
        
        // Ensure we have at least one input
        if videoInput == nil && audioInput == nil {
            throw CaptureDeviceError.noDevicesAvailable
        }
        
        try self.init(videoInput: videoInput,
                      audioInput: audioInput,
                      controlDelegate: controlDelegate,
                      cameraReader: cameraReader)
    }

    convenience init(_ position: AVCaptureDevice.Position,
                  controlDelegate: CameraControlDelegate,
                  cameraReader: AVReaderProtocol) throws
    {
        let videoDevice = try AVCaptureDevice.firstDevice(for: .video, in: position)
        let audioDevice = try AVCaptureDevice.firstDevice(for: .audio, in: position)
        
//        print(videoDevice.activeVideoMinFrameDuration)
//        print(videoDevice.activeVideoMaxFrameDuration)

        try self.init(videoDeviceID: videoDevice.uniqueID,
                      audioDeviceID: audioDevice.uniqueID,
                      controlDelegate: controlDelegate,
                      cameraReader: cameraReader)
    }
    
    public func start() {
        self.start(onComplete: nil)
    }
    
    public func start(onComplete: ((AVCaptureSession) -> Void)? = nil) {
        self.session.startRunning()
        onComplete?(self.session)
    }
    
    public func stop() {
        self.session.stopRunning()
    }
    
    private func setupObservers() {
        self.sessionObserver = self.session.observe(\.isRunning) { session, _ in
            if session.isRunning {
                self.controlDelegate.cameraStarted()
            } else {
                self.controlDelegate.cameraStopped()
            }
        }
    }
    
    deinit {
        self.sessionObserver?.invalidate()
    }
    
}
