import Buffie
import AVFoundation

class CameraOutputReader: CameraReader {
    
    var mp4Writer: MP4Writer?

    func setupWriter(with format: CMFormatDescription) {
        do { self.mp4Writer = try MP4Writer(URL(fileURLWithPath: "hi.mp4"), formatDescription: format) }
        catch { }
    }
    
    final override func got(_ sample: CMSampleBuffer, type: SampleType) {
        super.got(sample, type: type)
        guard let videoFormat = self.videoFormat else { return }
        guard let fileWriter  = self.mp4Writer else { self.setupWriter(with: videoFormat); return }
        
        if type == .video {
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

while 1 == 1 { }
