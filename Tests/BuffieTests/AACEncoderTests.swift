import XCTest
import CoreMedia
@testable import Buffie

class AACEncoderTests: XCTestCase {
    
    class AudioReader: AVReader {
        
        var encoder: AACEncoder?
        var encodeExp: XCTestExpectation?
        
        override func got(_ sample: CMSampleBuffer, type: SampleType) {
            super.got(sample, type: type)
            if type == .audio {
                self.encoder?.encode(sample) { data, status in
//                    XCTAssertNotNil(data)
//                    XCTAssertEqual(status, noErr)
                    self.encodeExp?.fulfill()
                }
            }
        }
    }
    

    func test_that_we_can_encode_pcm_samples_to_aac() {
        let encoder = AACEncoder()
        
        let reader  = AudioReader()
        reader.encoder = encoder
        
        let camera       = try? Camera(.back, reader: reader, controlDelegate: nil)
        reader.encodeExp = self.expectation(description: "Ensure we can encode pcm to aac")
        reader.encodeExp?.assertForOverFulfill = false
        
        camera?.start()
        self.wait(for: [reader.encodeExp!], timeout: 2)
    }
    
}
