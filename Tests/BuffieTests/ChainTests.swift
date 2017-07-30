import XCTest
import CoreMedia

typealias Filter        = (CIImage) -> CIImage
typealias CorePixelizer = (CIImage) -> CVPixelBuffer
typealias Samplizer     = (CVPixelBuffer) -> CMSampleBuffer

@available(macOS 10.11, iOS 5, *)
class ChainTests: XCTestCase {
    
    func test_building_a_chain() {
     
        let img = testPatternImage()
        
        let size = CGSize(width: 480, height: 640)
        let process = scale(size) >>> convertToCVPixelBuffer(size)
        
        process(img!)
        
    }
    
    static var allTests = [
        ("Building a chain", test_building_a_chain),
    ]

}
