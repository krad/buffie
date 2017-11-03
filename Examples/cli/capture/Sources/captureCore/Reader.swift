import Foundation
import AVFoundation
import Buffie


public class CameraOutputReader: CameraReader {
    
    var fileWriter: MovieFileWriter?
    var container: Container
    var url: URL
    
    public init(url: URL,
                recordTime: Int?,
                container: Container,
                bitrate: Int32,
                quality: Quality)
    {
        self.url       = url
        self.container = container
        super.init()
    }
    
    final public override func got(_ sample: CMSampleBuffer, type: SampleType) {
        super.got(sample, type: type)
        guard let videoFormat = self.videoFormat,
            let audioFormat = self.audioFormat
            else { return }

        if let writer = self.fileWriter {
            writer.write(sample, type: type)
        } else {
            self.setupWriter(with: videoFormat, and: audioFormat)
        }
    }
    
    final public func stop() {
        self.fileWriter?.stop() { }
    }
    
    private func setupWriter(with videoFormat: CMFormatDescription,
                             and audioFormat: CMFormatDescription) {
        do {
            switch self.container {
            case .mp4:
                self.fileWriter = try MP4Writer(url, videoFormat: videoFormat, audioFormat: audioFormat)
            case .m4v:
                self.fileWriter = try M4VWriter(url, videoFormat: videoFormat, audioFormat: audioFormat)
            case .mov:
                self.fileWriter = try MOVWriter(url, videoFormat: videoFormat, audioFormat: audioFormat)
            }
            
            self.fileWriter?.start()
            
        } catch {
            print("Couldn't create movie file writer")
            exit(-1)
        }
    }
}

