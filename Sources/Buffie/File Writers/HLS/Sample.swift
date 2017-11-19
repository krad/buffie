import Foundation
import CoreMedia

protocol Sample {
    var type: SampleType { get }
    var data: [UInt8] { get }
    var size: UInt32 { get }
}

public struct VideoSample: Sample {
    
    var type: SampleType
    var format: CMFormatDescription
    var nalus: [NALU] = []
    
    var data: [UInt8] {
        var results: [UInt8] = []
        for nalu in nalus {
            results.append(contentsOf: nalu.data)
        }
        return results
    }
    
    var duration: Int64          = 0
    var durationSeconds: Double  = 0
    var decode: Double           = 0
    var timescale: Double        = 0
    
    var size: UInt32 {
        return self.nalus.reduce(0, { last, nalu in last + nalu.totalSize })
    }
    
    var dependsOnOthers: Bool = false
    var isSync: Bool = false
    var earlierDisplayTimesAllowed: Bool = false
    
    init(sampleBuffer: CMSampleBuffer) {
        self.type       = .video
        self.format     = CMSampleBufferGetFormatDescription(sampleBuffer)!
        
        self.isSync                     = !sampleBuffer.notSync
        self.dependsOnOthers            = sampleBuffer.dependsOnOthers
        self.earlierDisplayTimesAllowed = sampleBuffer.earlierPTS
        
        if let bytes = bytes(from: sampleBuffer) {
            for nalu in NALUStreamIterator(streamBytes: bytes, currentIdx: 0) {
                self.nalus.append(nalu)
            }
        }
    }
    
}

public struct AudioSample: Sample {
    
    let type: SampleType
    let data: [UInt8]
    
    var size: UInt32 {
        return UInt32(self.data.count)
    }

    let sampleSize: UInt16
    let channels: UInt32
    let sampleRate: Double
    let audioObjectType: AudioObjectType
    let channelConfig: ChannelConfiguration
    let samplingFreq: SamplingFrequency
    let framesPerPacket: UInt32
    
    var duration: Double = 0
    var decode: Double   = 0
    
    init(sampleBuffer: CMSampleBuffer) {
        
        /// Set the type and data
        self.type       = .audio
        self.data       = bytes(from: sampleBuffer)!
        
        /// Get the stream description
        let asbd        = getStreamDescription(from: sampleBuffer)!

        /// Get sample size
        var packet      = AudioStreamPacketDescription()
        var packetSize: Int = 0
        CMSampleBufferGetAudioStreamPacketDescriptions(sampleBuffer, Int(asbd.mFramesPerPacket), &packet, &packetSize)
        self.sampleSize = UInt16(packetSize)
        
        /// Set the channels and sample rate
        self.channels   = asbd.mChannelsPerFrame
        self.sampleRate = asbd.mSampleRate
        
        /// Set flags for help with decoder
        self.audioObjectType = AudioObjectType(objectID: MPEG4ObjectID(rawValue: Int(asbd.mFormatFlags))!)
        self.channelConfig   = ChannelConfiguration(rawValue: UInt8(asbd.mChannelsPerFrame))!
        self.samplingFreq    = SamplingFrequency(sampleRate: asbd.mSampleRate)
        self.framesPerPacket  = asbd.mFramesPerPacket
                
    }
    

}

enum AudioObjectType: UInt8 {
    case AAC_Main     = 1
    case AAC_LC       = 2
    case AAC_SSR      = 3
    case AAC_LTP      = 4
    case AAC_SBR      = 5
    case AAC_Scalable = 6
    case TWIN_VQ      = 7
    case CELP         = 8
    case HVXC         = 9
    
    init(objectID: MPEG4ObjectID) {
        switch objectID {
        case .AAC_LC:
            self = .AAC_LC
        case .AAC_LTP:
            self = .AAC_LTP
        case .AAC_SBR:
            self = .AAC_SBR
        case .AAC_SSR:
            self = .AAC_SSR
        case .aac_Main:
            self = .AAC_Main
        case .aac_Scalable:
            self = .AAC_Scalable
        case .CELP:
            self = .CELP
        case .HVXC:
            self = .HVXC
        case .twinVQ:
            self = .TWIN_VQ
        }
    }
    
}

enum SamplingFrequency: UInt8 {
    
    case hz96000 = 0
    case hz88200 = 1
    case hz64000 = 2
    case hz48000 = 3
    case hz44100 = 4
    case hz32000 = 5
    case hz24000 = 6
    case hz22050 = 7
    case hz16000 = 8
    case hz12000 = 9
    case hz11025 = 10
    case hz8000  = 11
    case hz7350  = 12
    
    init(sampleRate: Double) {
        switch Int(sampleRate) {
        case 96000:
            self = .hz96000
        case 88200:
            self = .hz88200
        case 64000:
            self = .hz64000
        case 48000:
            self = .hz48000
        case 32000:
            self = .hz32000
        case 24000:
            self = .hz24000
        case 22050:
            self = .hz22050
        case 16000:
            self = .hz16000
        case 12000:
            self = .hz12000
        case 11025:
            self = .hz11025
        case 8000:
            self = .hz8000
        case 7350:
            self = .hz7350
        default:
            self = .hz44100
        }
    }
    
}

enum ChannelConfiguration: UInt8 {
    case frontCenter                                                                           = 1
    case frontLeftAndFrontRight                                                                = 2
    case frontCenterAndFrontLeftAndFrontRight                                                  = 3
    case frontCenterAndFrontLeftAndFrontRightAndBackCenter                                     = 4
    case frontCenterAndFrontLeftAndFrontRightAndBackLeftAndBackRight                           = 5
    case frontCenterAndFrontLeftAndFrontRightAndBackLeftAndBackRightLFE                        = 6
    case frontCenterAndFrontLeftAndFrontRightAndSideLeftAndSideRightAndBackLeftAndBackRightLFE = 7
}

