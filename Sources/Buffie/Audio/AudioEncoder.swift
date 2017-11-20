import Foundation
import AVFoundation
import AudioToolbox

internal struct AudioIO {
    var converter: AudioConverterRef
    var srcFormat: AudioStreamBasicDescription
    var dstFormat: AudioStreamBasicDescription
    var maxOutputPacketSize: UInt32
    
    var pcmBuffer: UnsafeMutablePointer<Int8>?
    var pcmBufferSize: Int?
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

        let blockBuffer = CMSampleBufferGetDataBuffer(sample)
        var bufferPtr: UnsafeMutablePointer<Int8>? = nil
        var bufferSize: Int = 0

        status = CMBlockBufferGetDataPointer(blockBuffer!, 0, nil, &bufferSize, &bufferPtr)
        
        if status != noErr { print("Couldn't get pointer to pcm data"); return }
        
        self.audioIO?.pcmBuffer     = bufferPtr
        self.audioIO?.pcmBufferSize = bufferSize

        
        var outBuffer = AudioBufferList.allocate(maximumBuffers: 1)
        outBuffer[0].mNumberChannels = 2
        outBuffer[0].mDataByteSize = UInt32(bufferSize)
        
        let ptr = UnsafeMutableRawPointer(bufferPtr!)
        outBuffer[0].mData = ptr
        
//        var outBuffer                      = AudioBufferList()
//        outBuffer.mNumberBuffers           = 1
//        outBuffer.mBuffers.mNumberChannels = audioIO.dstFormat.mChannelsPerFrame
//        outBuffer.mBuffers.mDataByteSize   = UInt32(bufferSize)
//        outBuffer.mBuffers.mData           = UnsafeMutableRawPointer.allocate(bytes: bufferSize, alignedTo: 0)
        
        var ioOutputDataPackets: UInt32 = 1
        
        status = AudioConverterFillComplexBuffer(audioIO.converter,
                                                 fillComplexCallback,
                                                 Unmanaged.passUnretained(self).toOpaque(),
                                                 &ioOutputDataPackets,
                                                 outBuffer.unsafeMutablePointer,
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
     
        let ptr = UnsafeMutableRawPointer(audioIO!.pcmBuffer!)
        ioData.pointee.mNumberBuffers           = 1
        ioData.pointee.mBuffers.mData           = ptr
        ioData.pointee.mBuffers.mDataByteSize   = UInt32(audioIO!.pcmBufferSize!)
        ioData.pointee.mBuffers.mNumberChannels = audioIO!.srcFormat.mChannelsPerFrame

        print(ioData.pointee)
        print("---", ioNumberDataPackets.pointee)
        
        let packetsWritten = (UInt32(audioIO!.pcmBufferSize!) / audioIO!.srcFormat.mChannelsPerFrame) / audioIO!.srcFormat.mBytesPerPacket
        print(packetsWritten)
        
        // https://developer.apple.com/library/content/qa/qa1317/_index.html
        ioNumberDataPackets.pointee = packetsWritten
        return noErr
    }
    
    private func setupConverter(with sample: CMSampleBuffer) {
        if var src = getStreamDescription(from: sample) {
            
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
            
            // Get the maximum output packet size
            var maxOutputPacketSize: UInt32 = 0
            var maxpktsize: UInt32 = 0
            status = AudioConverterGetProperty(converter!, kAudioConverterPropertyMaximumOutputPacketSize, &maxpktsize, &maxOutputPacketSize)
            if status != noErr { print("Couldn't max packet output size") }

            if audioIO == nil {
                self.audioIO = AudioIO(converter: converter!,
                                       srcFormat: src,
                                       dstFormat: realDst,
                                       maxOutputPacketSize: maxOutputPacketSize,
                                       pcmBuffer: nil,
                                       pcmBufferSize: nil)
            }
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
