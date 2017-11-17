import Foundation
import AVFoundation
import AudioToolbox

internal struct AudioIO {
    var converter: AudioConverterRef
    var srcFormat: AudioStreamBasicDescription
    var dstFormat: AudioStreamBasicDescription
    var maxOutputPacketSize: UInt32
    var packetsPerBuffer: UInt32
    var outputBufferSize: UInt32
    
    var inputBuffer: CMBlockBuffer?
    var packetDescriptions: UnsafeMutablePointer<AudioStreamPacketDescription>?

}

public class AACEncoder {
    
    var audioIO: AudioIO?
    
    var fillComplexCallback: AudioConverterComplexInputDataProc = { (inAudioConverter, ioDataPacketCount, ioData, outDataPacketDescriptionPtrPtr, inUserData) in
        return Unmanaged<AACEncoder>.fromOpaque(inUserData!).takeUnretainedValue().audioConverterCallback(
            ioDataPacketCount,
            ioData: ioData,
            outDataPacketDescription: outDataPacketDescriptionPtrPtr
        )
    }

    var encodedCallback: (CMSampleBuffer) -> Void
    
    init(onEncode: @escaping (CMSampleBuffer) -> Void) {
        self.encodedCallback = onEncode
    }
    
    public func encode(_ sample: CMSampleBuffer) {
        guard let _ = self.audioIO else {
            self.setupConverter(with: sample)
            self.process(sample)
            return
        }
        
        self.process(sample)
    }
    
    private func process(_ sample: CMSampleBuffer) {
        guard let audioIO = self.audioIO else { return }
        
        var status              = noErr
        var inBuffer            = AudioBufferList()
        inBuffer.mNumberBuffers = audioIO.srcFormat.mChannelsPerFrame
        var blockBuffer: CMBlockBuffer?
        var size: Int = 0
        
    
        status = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sample,
                                                                         &size,
                                                                         &inBuffer,
                                                                         AudioBufferList.sizeInBytes(maximumBuffers: Int(audioIO.srcFormat.mChannelsPerFrame)),
                                                                         kCFAllocatorDefault,
                                                                         kCFAllocatorDefault,
                                                                         0,
                                                                         &blockBuffer)
        
        if status != noErr {
            print("Couldn't prepare input samples: ", status)
            return
        }
        
        if blockBuffer == nil {
            print("Input sample buffer was nil")
            return
        }
        
        if let inputBuffer = self.audioIO?.inputBuffer {
            status = CMBlockBufferAppendBufferReference(inputBuffer,
                                               blockBuffer!,
                                               0,
                                               CMBlockBufferGetDataLength(blockBuffer!),
                                               0)
            if status != noErr {
                print("Could not concat buffer", status)
            }
            
        } else {
            self.audioIO?.inputBuffer = blockBuffer
        }
        
        
        var outBuffer                      = AudioBufferList()
        outBuffer.mNumberBuffers           = 1
        outBuffer.mBuffers.mNumberChannels = audioIO.dstFormat.mChannelsPerFrame
        outBuffer.mBuffers.mDataByteSize   = UInt32(CMBlockBufferGetDataLength(blockBuffer!)*2)
        outBuffer.mBuffers.mData           = UnsafeMutableRawPointer.allocate(bytes: Int(CMBlockBufferGetDataLength(blockBuffer!)*2), alignedTo: 0)
        
        var ioOutputDataPackets: UInt32 = 1
        
        var packet = AudioStreamPacketDescription()

        status = AudioConverterFillComplexBuffer(audioIO.converter,
                                                 fillComplexCallback,
                                                 Unmanaged.passUnretained(self).toOpaque(),
                                                 &ioOutputDataPackets,
                                                 &outBuffer,
                                                 nil)

        if status != noErr {
            print("Error converting:", status)
//            var x = 0
//            x += status == kAudioConverterErr_FormatNotSupported ? #line : 0
//            x += status == kAudioConverterErr_OperationNotSupported ? #line : 0
//            x += status == kAudioConverterErr_PropertyNotSupported ? #line : 0
//            x += status == kAudioConverterErr_InvalidInputSize ? #line : 0
//            x += status == kAudioConverterErr_InvalidOutputSize ? #line : 0
//            x += status == kAudioConverterErr_UnspecifiedError ? #line : 0
//            x += status == kAudioConverterErr_BadPropertySizeError ? #line : 0
//            x += status == kAudioConverterErr_RequiresPacketDescriptionsError ? #line : 0
//            x += status == kAudioConverterErr_InputSampleRateOutOfRange ? #line : 0
//            x += status == kAudioConverterErr_OutputSampleRateOutOfRange ? #line : 0
//
//            print(x)
            return
        } else {
            print("!!!!!!!!!!!!!VICTORY!!!!!!!!!!!!!!!")
        }

    }
    
    fileprivate func audioConverterCallback(
        _ ioNumberDataPackets: UnsafeMutablePointer<UInt32>,
        ioData: UnsafeMutablePointer<AudioBufferList>,
        outDataPacketDescription: UnsafeMutablePointer<UnsafeMutablePointer<AudioStreamPacketDescription>?>?) -> OSStatus
    {
        guard let audioIO = self.audioIO,
              let inBuffer = audioIO.inputBuffer,
              ((CMBlockBufferGetDataLength(inBuffer)/Int(audioIO.srcFormat.mChannelsPerFrame))/Int(audioIO.srcFormat.mBytesPerFrame)) >= Int(ioNumberDataPackets.pointee) else {
            ioNumberDataPackets.pointee = 0
            return -1
        }
        
        let bufferSize = ioNumberDataPackets.pointee * audioIO.srcFormat.mChannelsPerFrame * audioIO.srcFormat.mBytesPerFrame
        let ptr = UnsafeMutableRawPointer.allocate(bytes: Int(bufferSize), alignedTo: 0)
        var status = CMBlockBufferCopyDataBytes(audioIO.inputBuffer!, 0, Int(bufferSize), ptr)
        
        ioData.pointee.mNumberBuffers = 1
        ioData.pointee.mBuffers.mData = ptr
        ioData.pointee.mBuffers.mDataByteSize = bufferSize
        
//        print(audioIO.inputBuffer)
        print(ioData.pointee)
        print(ioNumberDataPackets.pointee)
        
        ioNumberDataPackets.pointee = 1

        return noErr
    }
    
    private func setupConverter(with sample: CMSampleBuffer) {
        if var src = getStreamDescription(from: sample) {
            
            print(src)
            print("---", src.mFormatFlags & kAudioFormatFlagIsNonInterleaved != 0)
                        
            var dst               = AudioStreamBasicDescription()
            dst.mSampleRate       = src.mSampleRate
            dst.mChannelsPerFrame = src.mChannelsPerFrame
            dst.mFormatID         = kAudioFormatMPEG4AAC
            dst.mFormatFlags      = 0
            dst.mFramesPerPacket  = 1024 // AAC packet size
            dst.mBytesPerPacket   = 0    // Signals VBR
            dst.mBytesPerFrame    = 0
            dst.mBitsPerChannel   = 0
            dst.mReserved         = 0
            
            //// Create the converter
            var status: OSStatus = noErr
            var converter: AudioConverterRef?
            status = AudioConverterNew(&src, &dst, &converter)
            if status != noErr {
                print("== Couldn't setup audio convert", status)
                return
            }
            
            // Get the REAL output stream description.  The one above isn't totally filled out
            var realDst     = AudioStreamBasicDescription()
            var realDstSize = UInt32(MemoryLayout.size(ofValue: realDst))
            status          = AudioConverterGetProperty(converter!, kAudioConverterCurrentOutputStreamDescription, &realDstSize, &realDst)
            if status != noErr { print("Couldn't get real dst stream description") }
            
            print(realDst)
            
            // Get the maximum output packet size
            var maxOutputPacketSize: UInt32 = 0
            var maxpktsize: UInt32 = 0
            status = AudioConverterGetProperty(converter!, kAudioConverterPropertyMaximumOutputPacketSize, &maxpktsize, &maxOutputPacketSize)
            if status != noErr { print("Couldn't max packet output size") }
            
            print(maxOutputPacketSize)
            
            var packetsPerBuffer: UInt32 = 0
            var outputBufferSize = UInt32(32 * 1024)
            if maxOutputPacketSize > outputBufferSize {
                outputBufferSize = maxOutputPacketSize
            }
            
            packetsPerBuffer = outputBufferSize / maxOutputPacketSize
            
            
            self.audioIO = AudioIO(converter: converter!,
                                   srcFormat: src,
                                   dstFormat: realDst,
                                   maxOutputPacketSize: maxOutputPacketSize,
                                   packetsPerBuffer: packetsPerBuffer,
                                   outputBufferSize: outputBufferSize,
                                   inputBuffer: nil,
                                   packetDescriptions: nil)
        }
    }
    
}


internal func getStreamDescription(from sample: CMSampleBuffer) -> AudioStreamBasicDescription? {
    if let formatDescription = CMSampleBufferGetFormatDescription(sample) {
        if let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription)?.pointee {
            return asbd
        }
    }
    return nil
}
