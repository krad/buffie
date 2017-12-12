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
                self.encoder?.encode(sample) { data, status, duration in
                    XCTAssertNotNil(data)
                    XCTAssertEqual(status, noErr)
                    XCTAssertNotNil(duration)
                    XCTAssertEqual(1024, duration?.value)
                    self.encodeExp?.fulfill()
                }
            }
        }
    }
    

    #if os(macOS)
    func test_that_we_can_encode_pcm_samples_to_aac() {
        
        let encoder = AACEncoder()
        let reader  = AudioReader()
        reader.encoder = encoder
        
        let camera       = try? Camera(.front, reader: reader, controlDelegate: nil)
        reader.encodeExp = self.expectation(description: "Ensure we can encode pcm to aac")
        reader.encodeExp?.assertForOverFulfill = false
        
        camera?.start()
        self.wait(for: [reader.encodeExp!], timeout: 2)
    }
    #endif

    #if os(iOS)
    func test_that_we_can_get_an_audio_description() {
        let result = getAudioClassDescription()
        XCTAssertNotNil(result)
    }
    #endif
}
