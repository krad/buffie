import XCTest
import CoreMedia
@testable import Buffie

@available(macOS 10.11, iOS 5, *)
class MP4WriterTests: XCTestCase {
    
    let videoURL = URL(fileURLWithPath: "\(outputsPath)/testVideo.mp4")

    override func setUp() {
        super.setUp()
        try? FileManager.default.removeItem(at: videoURL)
    }

    
    func test_writing_to_a_file() {
        
        XCTAssertNotNil(videoURL)
        XCTAssertFalse(FileManager.default.fileExists(atPath: videoURL.path))
        
        var settings                 = VideoEncoderSettings()
        settings.useHardwareEncoding = false
        settings.width               = 480
        settings.height              = 640
        
        let encoderDelegate = EncoderDelegate()
        let encoder         = try? VideoEncoder(settings, delegate: encoderDelegate)
        XCTAssertNotNil(encoder)
        
        let image  = testPatternImage()
        XCTAssertNotNil(image)
        
        let sample = buildSample(from: image!)
        XCTAssertNotNil(sample)
        
        XCTAssertNil(encoderDelegate.encodedSample)
        encoderDelegate.expectation = self.expectation(description: "encoding a video sample")
        encoder?.encode(sample!)
        encoder?.completeFrame()
        self.wait(for: [encoderDelegate.expectation!], timeout: 5)
        XCTAssertNotNil(encoderDelegate.encodedSample)

        let format          = CMSampleBufferGetFormatDescription(encoderDelegate.encodedSample!)
        XCTAssertNotNil(format)
        
        let decoderDelegate = DecoderDelegate()
        let decoder         = try? VideoDecoder(format: format!, delegate: decoderDelegate)
        XCTAssertNotNil(decoder)
        
        XCTAssertNil(decoderDelegate.decodedSample)
        decoderDelegate.expectation = self.expectation(description: "decoding a video sample")
        decoder?.decode(sample: encoderDelegate.encodedSample!)
        self.wait(for: [decoderDelegate.expectation!], timeout: 2)
        XCTAssertNotNil(decoderDelegate.decodedSample)
        
        let subject = try? MP4Writer(videoURL, formatDescription: format!)
        XCTAssertNotNil(subject)
        
        subject?.start(at: kCMTimeZero)
        subject?.write(decoderDelegate.decodedSample!, with: kCMTimeZero)
        for cnt in 0...48 {
            subject?.write(decoderDelegate.decodedSample!, with: CMTimeMakeWithSeconds(Double(cnt+1), 24))
        }
        subject?.stop(at: CMTimeMakeWithSeconds(49, 24))

        XCTAssertTrue(FileManager.default.fileExists(atPath: videoURL.path))

    }

    static var allTests = [
        ("Test writing to a file", test_writing_to_a_file),
    ]
    
}

