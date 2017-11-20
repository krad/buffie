import Foundation
import CoreMedia

struct StreamType: OptionSet {
    var rawValue: UInt8
    
    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    static let video = StreamType(rawValue: 1 << 0)
    static let audio = StreamType(rawValue: 1 << 1)
    
    func supported(_ sample: Sample) -> Bool {
        if self == [.video, .audio] { return true }
        if self == [.video] && sample.type == .video { return true }
        if self == [.audio] && sample.type == .audio { return true }
        return false
    }
    
}

protocol StreamSegmenterDelegate {
    func writeInitSegment(with config: MOOVConfig)
    func createNewSegment(with segmentID: Int, and sequenceNumber: Int)
    func writeMOOF(with samples: [Sample])
}

class StreamSegmenter {
    
    var outputDir: URL
    let targetSegmentDuration: Double
    var streamType: StreamType
    
    var currentSegment  = 0
    var currentSequence = 1
    
    internal var videoSamples: ThreadSafeArray<Sample>
    internal var videoSamplesDuration: Double {
        return self.videoSamples.reduce(0) { cnt, sample in cnt + sample.durationInSeconds }
    }
    
    internal var audioSamples: ThreadSafeArray<Sample>
    internal var audioSamplesDuration: Double {
        return self.audioSamples.reduce(0) { cnt, sample in cnt + sample.durationInSeconds }
    }
    
    internal var currentSegmentDuration: Double = 0.0
    

    private var segmenterQ = DispatchQueue(label: "stream.segmenter.Q")
    private var moovConfig = MOOVConfig()
    private var delegate: StreamSegmenterDelegate?
    private var wroteInitSegment: Bool = false

    var currentSegmentName: String {
        return "fileSeq\(self.currentSegment).mp4"
    }
    
    var currentSegmentURL: URL {
        return self.outputDir.appendingPathComponent(self.currentSegmentName)
    }
    
    internal var readyForMOOV: Bool {
        if self.streamType == [.video, .audio] {
            let presence: [Any?] = [moovConfig.videoSettings, moovConfig.audioSettings].filter { $0 != nil }
            if presence.count == 2 { return true }
        }

        if self.streamType == [.video] {
            let presence: [Any?] = [moovConfig.videoSettings].filter { $0 != nil }
            if presence.count != 0 { return true }
        }

        if self.streamType == [.audio] {
            let presence: [Any?] = [moovConfig.audioSettings].filter { $0 != nil }
            if presence.count != 0 { return true }
        }

        return false
    }

    init(outputDir: URL,
         targetSegmentDuration: Double,
         streamType: StreamType = [.video, .audio],
         delegate: StreamSegmenterDelegate? = nil) throws
    {
        self.outputDir             = outputDir
        self.targetSegmentDuration = targetSegmentDuration
        self.streamType            = streamType
        self.delegate              = delegate
        self.videoSamples          = ThreadSafeArray<Sample>()
        self.audioSamples          = ThreadSafeArray<Sample>()
    }
    
    func append(_ sample: Sample) {
        self.updateMOOVConfig(with: sample)
        if self.streamType.supported(sample) {
            
            self.buffer(sample: sample)
            
            if self.wroteInitSegment {
                self.handle(sample)
            } else {
                if self.readyForMOOV {
                    self.delegate?.writeInitSegment(with: self.moovConfig)
                    self.wroteInitSegment = true
                    self.handle(sample)
                }
            }
            
        }
    }
    
    private func handle(_ sample: Sample) {
        if self.currentSegment == 0 {
            self.currentSegment += 1
            self.delegate?.createNewSegment(with: self.currentSegment, and: self.currentSequence)
        } else {
            
            
            if sample.isSync {
                self.writeMOOF()
            }
        }
    }
    
    private func writeMOOF() {
        let samplesToWrite = self.vendSamples()
        self.delegate?.writeMOOF(with: samplesToWrite)
        self.currentSequence += 1
    }
    
    private func nearingTargetDuration(with nextDuration: Double) -> Bool {
        
        if streamType == [.video, .audio] {
            if (self.videoSamplesDuration + nextDuration) >= self.targetSegmentDuration &&
                (self.audioSamplesDuration + nextDuration) >= self.targetSegmentDuration {
                return true
            }
        }
        
        if streamType == [.video] {
            if self.videoSamplesDuration + nextDuration >= self.targetSegmentDuration {
                return true
            }
        }
        
        if streamType == [.audio] {
            if self.audioSamplesDuration + nextDuration >= self.targetSegmentDuration {
                return true
            }
        }
    
        return false
    }
    
    private func vendSamples() -> [Sample] {
        if streamType == [.video]         { return vendVideoSamples() }
        if streamType == [.audio]         { return vendAudioSamples() }
        if streamType == [.video, .audio] { return vendVideoSamples() + vendAudioSamples() }
        return []
    }
    
    private func vendVideoSamples() -> [Sample] {
        var results: [Sample] = []

        for (i, sample) in self.videoSamples.enumerated() {
            if sample.isSync {
                if i == 0 { results.append(sample) }
                else      { break }
            } else {
                results.append(sample)
            }
        }
        
        self.videoSamples.removeFirst(n: results.count)
        print(results.map { $0.isSync })
        return results
    }
    
    private func vendAudioSamples() -> [Sample] {
        var results: [Sample] = []
        
        for sample in self.audioSamples {
            results.append(sample)
        }
        
        self.audioSamples.removeFirst(n: results.count)
        return results
    }
    
    private func signalNewSegment() {
        self.currentSegment += 1
        self.delegate?.createNewSegment(with: self.currentSegment, and: self.currentSequence)
    }
    
    private func buffer(sample: Sample) {
        switch sample.type {
        case .audio: self.audioSamples.append(newElement: sample)
        case .video: self.videoSamples.append(newElement: sample)
        }
    }

    private func updateMOOVConfig(with sample: Sample) {
        switch sample.type {
        case .audio: self.moovConfig.audioSettings = MOOVAudioSettings(sample)
        case .video: self.moovConfig.videoSettings = MOOVVideoSettings(sample)
        }
    }
    
}

internal class ThreadSafeArray<T>: Collection {
    
    var startIndex: Int = 0
    var endIndex: Int {
        return self.count
    }

    private var array: [T] = []
    private let q = DispatchQueue(label: "threadSafeArray.q",
                                  qos: .default,
                                  attributes: .concurrent,
                                  autoreleaseFrequency: .inherit,
                                  target: nil)
    
    internal func append(newElement: T) {
        q.async(flags: .barrier) {
            self.array.append(newElement)
        }
    }
    
    internal func remove(at index: Int) {
        q.async(flags: .barrier) {
            self.array.remove(at: index)
        }
    }
    
    internal func removeFirst(n: Int) {
        q.async(flags: .barrier) {
            self.array.removeFirst(n)
        }
    }
    
    internal var count: Int {
        var count = 0
        q.sync {
            count = self.array.count
        }
        return count
    }
    
    internal var first: T? {
        var element: T?
        q.sync {
            element = self.array.first
        }
        return element
    }
    
    func index(after i: Int) -> Int {
        var index: Int = 0
        q.sync { index = self.array.index(after: i) }
        return index
    }

    
    internal subscript(index: Int) -> T {
        set {
            q.async(flags: .barrier) { self.array[index] = newValue }
        }
        
        get {
            var element: T!
            q.sync { element = self.array[index] }
            return element
        }
    }
    
}
