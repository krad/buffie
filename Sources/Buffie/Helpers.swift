import Foundation
import CoreMedia
import CoreImage

internal func scale(_ size: CGSize) -> Filter {
    return { img in
        let sx = CGFloat(size.width) / CGFloat(img.extent.size.width)
        let sy = CGFloat(size.height) / CGFloat(img.extent.size.height)
        let scaleTransform = CGAffineTransform(scaleX: sx, y: sy)
        return img.transformed(by: scaleTransform)
    }
}

@available(macOS 10.11, iOS 5, *)
internal func convertToCVPixelBuffer(_ size: CGSize) -> CorePixelizer {
    return { img in
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32BGRA, nil, &pixelBuffer)
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        let context = CIContext()
        context.render(img, to: pixelBuffer!)
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        return pixelBuffer!
    }
}

internal func convertToCMSampleBuffer(pts: CMTime?, format: CMVideoFormatDescription?) -> Samplizer {
    return { img in
        var realPts: CMTime? = nil
        realPts            = pts ?? kCMTimeInvalid
        var sampleTime = CMSampleTimingInfo(duration: kCMTimeInvalid,
                                            presentationTimeStamp: realPts!,
                                            decodeTimeStamp: kCMTimeInvalid)
        
        var videoFormat: CMVideoFormatDescription? = nil
        if let fmt = format {
            videoFormat = fmt
        } else {
            CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, img, &videoFormat)
        }
        
        var sample: CMSampleBuffer? = nil
        CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, img, true, nil, nil, videoFormat!, &sampleTime, &sample)
        
        return sample!
    }
}

precedencegroup PipelinePrecedence {
    associativity: left
}

infix operator >>>: PipelinePrecedence

internal func >>> (filter1: @escaping Filter, filter2: @escaping Filter) -> Filter {
    return { img in filter2(filter1(img)) }
}

internal func >>> (filter1: @escaping Filter, pixelizer: @escaping CorePixelizer) -> CorePixelizer {
    return { img in pixelizer(filter1(img)) }
}
