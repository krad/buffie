import Foundation
import CoreMedia

class FragmentedMP4Segment {
    
    // Current segment we're on.  Not even sure why this class knows about this
    var segmentNumber: Int = 0
    var file: URL
    var fileHandle: FileHandle
    
    /// Current moof we're on
    var currentSequence: Int
    
    var duration: CMTime = kCMTimeZero
    var prevDecodeTime: CMTime = kCMTimeZero
    
    var config: MOOVConfig
    
    var samples: [Sample] = []
    
    init(_ file: URL,
         config: MOOVConfig,
         segmentNumber: Int,
         currentSequence: Int = 1) throws
    {
        self.file     = file
        self.config  = config
        
        if !FileManager.default.fileExists(atPath: file.path) {
            FileManager.default.createFile(atPath: file.path, contents: nil, attributes: nil)
        }
        
        self.fileHandle      = try FileHandle(forWritingTo: file)
        self.segmentNumber   = segmentNumber
        self.currentSequence = currentSequence
    }
    
    func append(_ sample: Sample) {
        switch sample.type {
        case .video: self.handle(sample as! VideoSample)
        case .audio: self.samples.append(sample)
        }
    }
    
    func handle(_ sample: VideoSample) {
        self.duration = CMTimeAdd(duration, sample.duration)
        
        if sample.isSync && self.samples.count > 0 {
            try? self.write()
            self.samples.append(sample)
        } else {
            self.samples.append(sample)
        }
    }
    
    func write() throws {
        let moof = MOOF(config: self.config,
                        samples: samples,
                        currentSequence: UInt32(self.currentSequence))
        
        let mdat = MDAT(samples: samples)
        
        let moofBytes = try BinaryEncoder.encode(moof)
        let mdatBytes = try BinaryEncoder.encode(mdat)
        
        let data = Data(bytes: moofBytes + mdatBytes)
        self.fileHandle.write(data)
        
        let videoSamples    = samples.filter { $0.type == .video } as! [VideoSample]
        self.prevDecodeTime = videoSamples.reduce(kCMTimeZero) { (cnt, sample) in
            CMTimeAdd(cnt, sample.duration)
        }
        self.currentSequence += 1
        self.samples = []
    }
    
}

