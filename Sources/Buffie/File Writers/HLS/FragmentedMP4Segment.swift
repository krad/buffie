import Foundation
import CoreMedia

class FragmentedMP4Segment {
    
    // Current segment we're on.  Not even sure why this class knows about this
    var segmentNumber: Int = 0
    var file: URL
    var fileHandle: FileHandle
    
    /// Current moof we're on
    var currentSequence: Int
    
    var duration: Double = 0
    
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
        self.duration += sample.durationSeconds
        
        if sample.isSync && self.samples.count > 0 {
            try? self.write()
            self.samples.append(sample)
        } else {
            self.samples.append(sample)
        }
    }
    
    func write() throws {
        
        let audioSamples = self.samples.filter { $0.type == .audio } as! [AudioSample]
        let duration = audioSamples.reduce(0) { cnt, sample in cnt + sample.duration }
        print(duration, audioSamples.count, duration / 44100)
        
        let moof = MOOF(config: self.config,
                        samples: samples,
                        currentSequence: UInt32(self.currentSequence))
        
        let mdat = MDAT(samples: samples)
        
        let moofBytes = try BinaryEncoder.encode(moof)
        let mdatBytes = try BinaryEncoder.encode(mdat)
        
        let data = Data(bytes: moofBytes + mdatBytes)
        self.fileHandle.write(data)
        
        self.currentSequence += 1
        self.samples = []
    }
    
}

