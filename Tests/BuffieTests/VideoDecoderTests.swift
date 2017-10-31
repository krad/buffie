import XCTest
import CoreMedia
@testable import Buffie

@available(macOS 10.11, iOS 5, *)
class VideoDecoderTests: XCTestCase {

    func test_decoding_samples() {

        var settings                 = VideoEncoderSettings()
        settings.useHardwareEncoding = false

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
        let subject         = try? VideoDecoder(format: format!, delegate: decoderDelegate)
        XCTAssertNotNil(subject)

        XCTAssertNil(decoderDelegate.decodedSample)
        decoderDelegate.expectation = self.expectation(description: "decoding a video sample")
        subject?.decode(sample: encoderDelegate.encodedSample!)
        self.wait(for: [decoderDelegate.expectation!], timeout: 2)
        XCTAssertNotNil(decoderDelegate.decodedSample)

    }

    static var allTests = [
        ("Test Decoding Samples", test_decoding_samples),
    ]

}

