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
    private var pcmBuffer: [UInt8] = []
    private var pcmBufferSize: UInt32
    
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
                outASBD.mFormatFlags        = UInt32(MPEG4ObjectID.AAC_LC.rawValue)
                outASBD.mBytesPerPacket     = 0
                outASBD.mFramesPerPacket    = 1024
                outASBD.mBytesPerFrame      = 0
                outASBD.mChannelsPerFrame   = 1
                outASBD.mBitsPerChannel     = 0
                outASBD.mReserved           = 0
                
//                #if os(macOS)
                    let status = AudioConverterNew(&inASBD, &outASBD, &audioConverter)
                    if status != noErr { print("Failed to setup converter:", status) }
//                #else
//                if var descriptor = self.getAudioClassDescription(with: kAudioFormatMPEG4AAC,
//                                                                  from: kAppleSoftwareAudioCodecManufacturer) {
//
//                    let status = AudioConverterNewSpecific(&inASBD,
//                                                           &outASBD,
//                                                           1,
//                                                           &descriptor,
//                                                           &audioConverter)
//                    if status != noErr { print("Failed to setup converter:", status) }
//
//                }
//                #endif

            }
        }
    }
    
    public func encode(_ sampleBuffer: CMSampleBuffer, onComplete: @escaping (Data?, OSStatus) -> Void) {
        self.encoderQ.async {
            if self.audioConverter == nil { self.setupEncoder(from: sampleBuffer) }
            guard let audioConverter = self.audioConverter else { return }
        
            if let sampleBytes = bytes(from: sampleBuffer) {
                self.pcmBuffer     = sampleBytes
                self.pcmBufferSize = UInt32(sampleBytes.count)
            }
            
            self.aacBuffer = [UInt8](repeating: 0, count: 1024)
            
            let outBuffer:UnsafeMutableAudioBufferListPointer = AudioBufferList.allocate(maximumBuffers: 1)
            outBuffer[0].mNumberChannels = 2
            outBuffer[0].mDataByteSize = self.pcmBufferSize
            outBuffer[0].mData = UnsafeMutableRawPointer.allocate(bytes: Int(self.pcmBufferSize), alignedTo: 0)
            
//            var outBuffer                      = AudioBufferList()
//            outBuffer.mNumberBuffers           = 1
//            outBuffer.mBuffers.mNumberChannels = 1
//            outBuffer.mBuffers.mDataByteSize   = 1024
        
            var ioOutputDataPacketSize: UInt32 = 1
        
            let status = AudioConverterFillComplexBuffer(audioConverter,
                                                         self.fillComplexCallback,
                                                         Unmanaged.passUnretained(self).toOpaque(),
                                                         &ioOutputDataPacketSize,
                                                         outBuffer.unsafeMutablePointer,
                                                         nil)
        
            if status == noErr {
                let rawAAC = Data(self.aacBuffer)
                onComplete(rawAAC, noErr)
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
        print(#function)
        let requestedPackets = ioNumberDataPackets.pointee
        self.pcmBuffer.withUnsafeMutableBufferPointer { bufferPtr in
            let ptr                              = UnsafeMutableRawPointer(bufferPtr.baseAddress)
            ioData.pointee.mBuffers.mData        = ptr
            ioData.pointee.mBuffers.mDataByteSize = self.pcmBufferSize
            print(ioData)
        }
        
        if self.pcmBufferSize < requestedPackets {
            print("Fuck")
            ioNumberDataPackets.pointee = 0
            return -1
        }
        
        print("Next")
        ioNumberDataPackets.pointee = 1
        return noErr
    }
    

    // http://stackoverflow.com/questions/10817036/can-i-use-avcapturesession-to-encode-an-aac-stream-to-memory
    private func getAudioClassDescription(with type: UInt32,
                                          from manufacturer: UInt32) -> AudioClassDescription?
    {
        var status = noErr
        
        var encoderSpec: UInt32 = type
        var size: UInt32 = 0
        status = AudioFormatGetPropertyInfo(kAudioFormatProperty_Encoders,
                                            type,
                                            &encoderSpec,
                                            &size)
        
        if status != noErr {
            print("Error getting audio format property", status)
            return nil
        }
        
        var descriptions: [AudioClassDescription] = []
        status = AudioFormatGetProperty(kAudioFormatProperty_Encoders,
                                        type,
                                        &encoderSpec,
                                        &size,
                                        &descriptions)
        
        if status != noErr {
            print("Error getting audio format property", status)
            return nil
        }
        
        for descriptor in descriptions {
            if descriptor.mSubType == type && descriptor.mManufacturer == manufacturer {
                return descriptor
            }
        }
        
        return nil
    }
    
}
