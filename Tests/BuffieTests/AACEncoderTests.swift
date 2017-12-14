import XCTest
import CoreMedia
import Foundation
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
    
    func test_that_we_can_convert_8_bit_integers_to_signed_16_bit_integers() {
        
        let sampleBytes: [UInt8] = [44, 44,
                                    44, 44,
                                    44, 44,
                                    44, 44,
                                    44, 44,
                                    44, 44,
                                    44, 44,
                                    44, 44,
                                    44, 44,
                                    44, 44]

        // Convert 8 bit intergers to signed 16bit integers
        let data = NSData(bytes: sampleBytes, length: sampleBytes.count)
        XCTAssertNotEqual(0, data.length)
        XCTAssertEqual(20, data.length)
        
        let count = sampleBytes.count / MemoryLayout<Int16>.size

        var actualSamples = [Int16](repeating: 0, count: count)
        data.getBytes(&actualSamples, length: count)
        
        XCTAssertNotEqual(0, actualSamples.count)
        XCTAssertEqual(10, actualSamples.count)

        print(actualSamples)
        XCTAssertEqual(11308, actualSamples.first)
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
