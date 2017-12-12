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
    private var pcmBuffer: [UInt8]     = []
    private var pcmBufferSize: UInt32
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
        self.pcmBufferSize  = 0
    }
    
    func setupEncoder(from sampleBuffer: CMSampleBuffer) {
        
        if let format = CMSampleBufferGetFormatDescription(sampleBuffer) {
            if var inASBD = CMAudioFormatDescriptionGetStreamBasicDescription(format)?.pointee {
                
                var outASBD                 = AudioStreamBasicDescription()
                outASBD.mSampleRate         = inASBD.mSampleRate
                outASBD.mFormatID           = kAudioFormatMPEG4AAC
                outASBD.mFormatFlags        = 0
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
        
            if let sampleBytes = bytes(from: sampleBuffer) {
                self.pcmBuffer     = sampleBytes
                self.pcmBufferSize = UInt32(sampleBytes.count)
            }
            
            self.aacBuffer = [UInt8](repeating: 0, count: Int(self.pcmBufferSize))
            
            let outBuffer:UnsafeMutableAudioBufferListPointer = AudioBufferList.allocate(maximumBuffers: 1)
            outBuffer[0].mNumberChannels = self.outASBD == nil ? 1 : self.outASBD!.mChannelsPerFrame
            outBuffer[0].mDataByteSize = self.pcmBufferSize
            
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
        
            if status == noErr {
                //let aacPayload = Array(self.aacBuffer[0..<Int(outBuffer[0].mDataByteSize)])
                onComplete(self.aacBuffer, noErr)
            } else {
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
        self.pcmBuffer.withUnsafeMutableBufferPointer { bufferPtr in
            let ptr                              = UnsafeMutableRawPointer(bufferPtr.baseAddress)
            ioData.pointee.mBuffers.mData        = ptr
            ioData.pointee.mBuffers.mDataByteSize = self.pcmBufferSize
        }
        
        if self.pcmBufferSize < requestedPackets {
            ioNumberDataPackets.pointee = 0
            return -1
        }
        
        ioNumberDataPackets.pointee = 1
        return noErr
    }
}
