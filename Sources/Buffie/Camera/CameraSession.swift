import Foundation
import AVKit

internal protocol CameraSessionProtocol {
    var videoOutput: AVCaptureVideoDataOutput { get }
    var audioOutput: AVCaptureAudioDataOutput { get }

    func start()
    func stop()
}

internal class CameraSession: CameraSessionProtocol {
    
    private var controlDelegate: CameraControlDelegate
    
    @objc private var session: AVCaptureSession
    var sessionObserver: NSKeyValueObservation?
    
    private var videoDevice: AVCaptureDevice
    private var videoInput: AVCaptureDeviceInput
    
    internal var videoOutput: AVCaptureVideoDataOutput
    private let videoQueue = DispatchQueue(label: "videoQ")
    
    private var audioDevice: AVCaptureDevice
    private var audioInput: AVCaptureDeviceInput
    
    internal var audioOutput: AVCaptureAudioDataOutput
    private let audioQueue = DispatchQueue(label: "audioQ")
    
    required init(videoDeviceID: String,
                  audioDeviceID: String,
                  controlDelegate: CameraControlDelegate,
                  cameraReader: CameraReaderProtocol) throws
    {
        self.controlDelegate = controlDelegate
        self.session         = AVCaptureSession()
        
        // Setup the video device & i/o
        if let videoDevice = AVCaptureDevice(uniqueID: videoDeviceID) { self.videoDevice = videoDevice }
        else { throw CameraError.deviceNotFound(deviceID: videoDeviceID) }
        self.videoInput      = try AVCaptureDeviceInput(device: self.videoDevice)
        self.videoOutput     = AVCaptureVideoDataOutput()
        
        // Setup the audio device & i/o
        if let audioDevice = AVCaptureDevice(uniqueID: audioDeviceID) { self.audioDevice = audioDevice }
        else { throw CameraError.deviceNotFound(deviceID: audioDeviceID) }
        self.audioInput      = try AVCaptureDeviceInput(device: self.audioDevice)
        self.audioOutput     = AVCaptureAudioDataOutput()
        
        // Add that i/o to the session
        self.session.addInput(self.videoInput)
        self.session.addInput(self.audioInput)
        
        self.session.addOutput(self.videoOutput)
        self.session.addOutput(self.audioOutput)
        
        self.videoOutput.setSampleBufferDelegate(cameraReader.videoReader, queue: videoQueue)
        self.audioOutput.setSampleBufferDelegate(cameraReader.audioReader, queue: audioQueue)
        
        self.setupObservers()
        
    }

    convenience init(_ position: AVCaptureDevice.Position,
                  controlDelegate: CameraControlDelegate,
                  cameraReader: CameraReaderProtocol) throws
    {
        let videoDevice = try AVCaptureDevice.firstDevice(for: .video, in: position)
        let audioDevice = try AVCaptureDevice.firstDevice(for: .audio, in: position)
        try self.init(videoDeviceID: videoDevice.uniqueID,
                      audioDeviceID: audioDevice.uniqueID,
                      controlDelegate: controlDelegate,
                      cameraReader: cameraReader)
    }
    
    func start() {
        self.session.startRunning()
    }
    
    func stop() {
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
