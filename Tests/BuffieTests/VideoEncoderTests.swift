import XCTest
import CoreMedia
@testable import Buffie

@available(macOS 10.11, iOS 5, *)
class EncoderTests: XCTestCase {
    
    func test_basic_object_behavior() {
        
        var settings                 = VideoEncoderSettings()
        settings.useHardwareEncoding = false
        
        let mockDelegate = EncoderDelegate()
        let subject      = try? VideoEncoder(settings, delegate: mockDelegate)
        XCTAssertNotNil(subject)
        
        let image  = testPatternImage()
        XCTAssertNotNil(image)
        
        let sample = buildSample(from: image!)
        XCTAssertNotNil(sample)
        
        mockDelegate.expectation = self.expectation(description: "encoding a video sample")
        subject?.encode(sample!)
        subject?.completeFrame()
        self.wait(for: [mockDelegate.expectation!], timeout: 5)
        
    }
    
    static var allTests = [
        ("Test Basic Behavior", test_basic_object_behavior),
    ]
    
}

@available(macOS 10.11, iOS 5, *)
func buildSample(from image: CIImage) -> CMSampleBuffer? {
    let size    = CGSize(width: 480, height: 640)
    let conversion = scale(size) >>> convertToCVPixelBuffer(size)
    let pixelBuffer = conversion(image)
    return convertToCMSampleBuffer(pts: nil, format: nil)(pixelBuffer)
}

func testPatternImage() -> CIImage? {
    let imgURL = URL(fileURLWithPath: "\(fixturesPath)/testPattern.png")
    let image  = CIImage(contentsOf: imgURL)
    return image
}

let fixturesPath = "\(kProjectDir)/Tests/BuffieTests/Fixtures"
let outputsPath = "\(kProjectDir)/Tests/BuffieTests/Outputs"
