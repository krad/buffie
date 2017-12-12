import Foundation
import AudioToolbox
import CoreMedia
import Dispatch

public class AACEncoder {
    
    private var encoderQ  = DispatchQueue(label: "aac.encoder.q")
    private var callbackQ = DispatchQueue(label: "aac.encoder.callback.q")
    
    private var audioConverter: AudioConverterRef?
    fileprivate var aacBuffer: [UInt8] = []
    fileprivate var aacBufferSize: UInt32
    private var pcmBuffer: [[UInt8]] = []
    private var outASBD: AudioStreamBasicDescription?
    
    fileprivate var fillComplexCallback: AudioConverterComplexInputDataProc = { (inAudioConverter, 
        ioDataPacketCount, ioData, outDataPacketDescriptionPtrPtr, inUserData) in
        return Unmanaged<AACEncoder>.fromOpaque(inUserData!).takeUnretainedValue().audioConverterCallback(
            ioDataPacketCount,
            ioData: ioData,
            outDataPacketDescription: outDataPacketDescriptionPtrPtr
        )
    }
    
    public init() {
        self.audioConverter = nil
        self.aacBufferSize  = 1024
    }
    
    func setupEncoder(from sampleBuffer: CMSampleBuffer) {
        
        if let format = CMSampleBufferGetFormatDescription(sampleBuffer) {
            if var inASBD = CMAudioFormatDescriptionGetStreamBasicDescription(format)?.pointee {
                var outASBD                 = AudioStreamBasicDescription()
                outASBD.mSampleRate         = inASBD.mSampleRate
                outASBD.mFormatID           = kAudioFormatMPEG4AAC
                outASBD.mFormatFlags        = UInt32(MPEG4ObjectID.AAC_LC.rawValue)
                outASBD.mBytesPerPacket     = 0
                outASBD.mFramesPerPacket    = 1024
                outASBD.mBytesPerFrame      = 0
                outASBD.mChannelsPerFrame   = inASBD.mChannelsPerFrame
                outASBD.mBitsPerChannel     = 0
                outASBD.mReserved           = 0
                self.outASBD                = outASBD
                
                let status = AudioConverterNew(&inASBD, &outASBD, &audioConverter)
                if status != noErr { print("Failed to setup converter:", status) }
            }
        }
    }
    
    public func encode(_ sampleBuffer: CMSampleBuffer, onComplete: @escaping ([UInt8]?, OSStatus) -> Void) {
        self.encoderQ.async {
            if self.audioConverter == nil { self.setupEncoder(from: sampleBuffer) }
            guard let audioConverter = self.audioConverter else { return }
        
            var pcmBufferSize: UInt32 = 0
            if let sampleBytes = bytes(from: sampleBuffer) {
                if CMSampleBufferGetNumSamples(sampleBuffer) < 1024 {
                    if var prevBuffer = self.pcmBuffer.last {
                        prevBuffer.append(contentsOf: sampleBytes)
                        self.pcmBuffer.removeLast()
                        self.pcmBuffer.append(prevBuffer)
                    } else {
                        self.pcmBuffer.append(sampleBytes)
                        return
                    }
                } else {
                    self.pcmBuffer.append(sampleBytes)
                }
                
                pcmBufferSize = UInt32(sampleBytes.count)
            }
            
            self.aacBuffer = [UInt8](repeating: 0, count: Int(pcmBufferSize))
            
            let outBuffer:UnsafeMutableAudioBufferListPointer = AudioBufferList.allocate(maximumBuffers: 1)
            outBuffer[0].mNumberChannels    = self.outASBD == nil ? 1 : self.outASBD!.mChannelsPerFrame
            outBuffer[0].mDataByteSize      = pcmBufferSize
            
            self.aacBuffer.withUnsafeMutableBytes({ rawBufPtr in
                let ptr = rawBufPtr.baseAddress
                outBuffer[0].mData = ptr
            })
            
            var ioOutputDataPacketSize: UInt32 = 1
        
            let status = AudioConverterFillComplexBuffer(audioConverter,
                                                         self.fillComplexCallback,
                                                         Unmanaged.passUnretained(self).toOpaque(),
                                                         &ioOutputDataPacketSize,
                                                         outBuffer.unsafeMutablePointer,
                                                         nil)
        
            switch status {
            case noErr:
                let aacPayload = Array(self.aacBuffer[0..<Int(outBuffer[0].mDataByteSize)])
                onComplete(aacPayload, noErr)
            case -1:
                print("Needed more bytes")
            default:
                print("Error converting buffer:", status)
                onComplete(nil, status)
            }
        }
    }
    

    fileprivate func audioConverterCallback(
        _ ioNumberDataPackets: UnsafeMutablePointer<UInt32>,
        ioData: UnsafeMutablePointer<AudioBufferList>,
        outDataPacketDescription: UnsafeMutablePointer<UnsafeMutablePointer<AudioStreamPacketDescription>?>?) -> OSStatus
    {
        let requestedPackets = ioNumberDataPackets.pointee
        
        var pcmBufferSize: UInt32 = 0
        if var pcmBuffer = self.pcmBuffer.first {
            
            pcmBufferSize = UInt32(pcmBuffer.count)
            pcmBuffer.withUnsafeMutableBufferPointer { bufferPtr in
                let ptr                               = UnsafeMutableRawPointer(bufferPtr.baseAddress)
                ioData.pointee.mBuffers.mData         = ptr
                ioData.pointee.mBuffers.mDataByteSize = pcmBufferSize
            }
            
        } else {
            ioNumberDataPackets.pointee = 0
            return -1
        }
        
        if pcmBufferSize < requestedPackets {
            ioNumberDataPackets.pointee = 0
            return -1
        }
        
        self.pcmBuffer.removeFirst()
        ioNumberDataPackets.pointee = 1
        return noErr
    }
}
