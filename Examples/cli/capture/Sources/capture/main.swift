import Buffie
import Dispatch
import AVFoundation

// Ignore signal interupt
signal(SIGINT, SIG_IGN)
var done = false

class CameraOutputReader: CameraReader {
    
    var mp4Writer: MP4Writer?
    let sigintSrc = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
    
    var currentTime: CMTime?
    
    override init() {
        super.init()
        sigintSrc.setEventHandler {
            guard let time = self.currentTime else { return }
            self.mp4Writer?.stop(at: time) {
                done = true
                exit(0);
            }
        }
        sigintSrc.resume()
    }

    func setupWriter(with format: CMFormatDescription) {
        guard let time = self.currentTime else { return }
        do {
            self.mp4Writer = try MP4Writer(URL(fileURLWithPath: "hi.mp4"), formatDescription: format)
            self.mp4Writer?.start(at: time)
        }
        catch {
            
        }
    }
    
    final override func got(_ sample: CMSampleBuffer, type: SampleType) {
        super.got(sample, type: type)
        guard let videoFormat = self.videoFormat else { return }
        guard let fileWriter  = self.mp4Writer else {
            if type == .video {
                self.currentTime = CMSampleBufferGetPresentationTimeStamp(sample)
                self.setupWriter(with: videoFormat)
            }
            return
        }
        
        if type == .video {
            self.currentTime = CMSampleBufferGetPresentationTimeStamp(sample)
            fileWriter.write(sample)
        }
    }
}

do {
    let cameraReader = CameraOutputReader()
    let camera       = try Camera(.back, reader: cameraReader, controlDelegate: nil)
    camera.start()
} catch {
    print("Couldn't access camera")
}

while !done {
    dispatchMain()
}
