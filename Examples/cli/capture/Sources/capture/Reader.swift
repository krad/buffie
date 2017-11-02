import Foundation
import AVFoundation
import Buffie

class CameraOutputReader: CameraReader {
    
    var mp4Writer: MP4Writer?
    
    override init() {
        super.init()
    }
    
    final override func got(_ sample: CMSampleBuffer, type: SampleType) {
        super.got(sample, type: type)
//        guard let videoFormat = self.videoFormat,
//            let audioFormat = self.audioFormat
//            else { return }
//
//        if let fileWriter = self.mp4Writer {
//            fileWriter.write(sample, type: type)
//        }
    }
}
