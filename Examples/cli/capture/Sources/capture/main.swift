import Buffie
import Dispatch
import AVFoundation

// Ignore signal interupt
signal(SIGINT, SIG_IGN)
var done = false

print(AVOutputSettingsAssistant.availableOutputSettingsPresets())

class CameraOutputReader: CameraReader {
    
    var mp4Writer: MP4Writer?
    let sigintSrc = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
    
    override init() {
        super.init()
        sigintSrc.setEventHandler {
            self.mp4Writer?.stop() {
                done = true
                exit(0);
            }
        }
        sigintSrc.resume()
    }

    func setupWriter(with videoFormat: CMFormatDescription, and audioFormat: CMFormatDescription) {
        if self.mp4Writer != nil { return }
        
        do {
            self.mp4Writer = try MP4Writer(URL(fileURLWithPath: "hi.m4v"),
                                           videoFormat: videoFormat,
                                           audioFormat: audioFormat)
            self.mp4Writer?.start()
        }
        catch {
            
        }
    }
    
    final override func got(_ sample: CMSampleBuffer, type: SampleType) {
        super.got(sample, type: type)
        guard let videoFormat = self.videoFormat,
              let audioFormat = self.audioFormat
        else { return }
        
        if let fileWriter = self.mp4Writer {
            fileWriter.write(sample, type: type)
        } else {
            DispatchQueue.main.sync {
                self.setupWriter(with: videoFormat, and: audioFormat)
            }
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
