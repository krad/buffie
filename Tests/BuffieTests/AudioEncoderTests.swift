import XCTest
import CoreMedia
import AVKit
@testable import Buffie

//@available(OSX 10.11, iOS 5, *)
class AudioEncoderTests: XCTestCase {

    class AudioReader: AVReader {
        
        var encoder: AACEncoder?
        
        override func got(_ sample: CMSampleBuffer, type: SampleType) {
            super.got(sample, type: type)
            if type == .audio {
                self.encoder?.encode(sample)
            }
        }
        
    }
    
    func xtest_new_aac_encoder() {
        
        let e = self.expectation(description: "Encoded an AAC sample")
        let encoder = AACEncoder() { sample in
            e.fulfill()
        }
        
        let reader     = AudioReader()
        reader.encoder = encoder
        let camera = try? Camera(.back, reader: reader, controlDelegate: nil)
        XCTAssertNotNil(camera)
        
        camera?.start()
        
        self.wait(for: [e], timeout: 2)
        
    }

//    static var allTests = [
//        ("test_new_aac_encoder", test_new_aac_encoder),
//    ]

}

