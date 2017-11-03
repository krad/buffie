import Foundation
import AVFoundation

internal func createSample(from buffer: [UInt8], format: CMFormatDescription) -> CMSampleBuffer? {
    
    var timingInfo = timingInfoFrom(buffer, ptsAppended: false)
    if let blockBuffer = blockBuffer(from: buffer) {
        if let sample = sample(from: blockBuffer, timingInfo: &timingInfo, format: format) {
            return sample
        }
    }
    
    return nil
}

/// Build a timing info struct from a stream of bytes
///
/// - Parameters:
///   - bytes: stream of bytes that MIGHT have timing info appended
///   - ptsAppended: If the last 8 bytes of the bytes have a timestamp
/// - Returns: CMSampleTimingInfoStruct
internal func timingInfoFrom(_ bytes: [UInt8], ptsAppended: Bool) -> CMSampleTimingInfo {
    
    let duration        = kCMTimeInvalid
    var presentation    = kCMTimeInvalid
    let decode          = kCMTimeInvalid
    
    if ptsAppended {
        let ptsBytes    = Array(bytes[bytes.endIndex-8..<bytes.endIndex])
        let ptsValue    = Int64(bytes: ptsBytes)!
        presentation    = CMTime(value: ptsValue, timescale: 600, flags: CMTimeFlags.valid, epoch: 0)
    }
    
    return CMSampleTimingInfo(duration: duration,
                              presentationTimeStamp: presentation,
                              decodeTimeStamp: decode)
}


/// Returns a block buffer constructed from an array of bytes
///
/// - Parameter bytes: Bytes you want to bind to a block buffer
/// - Returns: CMBlockBuffer
internal func blockBuffer(from bytes: [UInt8]) -> CMBlockBuffer? {
    
    //    let naluWithLength  = prependLengthToBytes(bytes)
    let naluData        = data(from: bytes)
    var status          = noErr
    
    var blockBuffer: CMBlockBuffer?
    status = CMBlockBufferCreateEmpty(nil, 1, 0, &blockBuffer)
    if status != noErr {
        return nil
    }
    
    if let blockBufferRef = blockBuffer {
        let dataPtr = UnsafeMutablePointer<UInt8>(mutating: (naluData as NSData).bytes.bindMemory(to: UInt8.self, capacity: naluData.count))
        status = CMBlockBufferAppendMemoryBlock(blockBufferRef, dataPtr, naluData.count, kCFAllocatorNull, nil, 0, naluData.count, 0)
        
        if status != noErr {
            return nil
        }
        
        return blockBufferRef
    }
    
    return nil
    
}

internal func data(from bytes: [UInt8]) -> Data {
    return Data(bytes)
}

internal func sample(from blockBuffer: CMBlockBuffer, timingInfo: inout CMSampleTimingInfo, format: CMFormatDescription) -> CMSampleBuffer? {
    
    var status = noErr
    var sample: CMSampleBuffer? = nil
    var sampleSizeArray: [size_t] = [CMBlockBufferGetDataLength(blockBuffer)]
    
    status = CMSampleBufferCreate(kCFAllocatorDefault,
                                  blockBuffer,
                                  true,
                                  nil,
                                  nil,
                                  format,
                                  1,
                                  1,
                                  &timingInfo,
                                  1,
                                  &sampleSizeArray,
                                  &sample)
    
    if status != noErr { return nil }
    return sample
}


/// Adds an attachment to a CMSampleBuffer
///
/// - Parameters:
///   - key: Key name of the attachment
///   - value: Value of the attachment
///   - sample: Sample to attach to
internal func addAttachment(key: CFString, value: CFBoolean, to sample: inout CMSampleBuffer) {
    if let attachments: CFArray = CMSampleBufferGetSampleAttachmentsArray(sample, true) {
        let attachment: CFMutableDictionary = unsafeBitCast(CFArrayGetValueAtIndex(attachments, 0), to: CFMutableDictionary.self)
        CFDictionarySetValue(attachment, Unmanaged.passUnretained(key).toOpaque(), Unmanaged.passUnretained(value).toOpaque())
    }
}
