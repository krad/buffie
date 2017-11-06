import XCTest
import AVFoundation
@testable import Buffie

class DeviceEnumerationTests: XCTestCase {

    func test_that_we_can_get_a_list_of_available_video_devices() {
        XCTAssertNotNil(AVCaptureDevice.videoDevices())
        XCTAssert(AVCaptureDevice.videoDevices().count > 0 )
     
        XCTAssertNotNil(AVCaptureDevice.videoDevicesDictionary())
        XCTAssert(AVCaptureDevice.videoDevicesDictionary().keys.count > 0)
        
        let deviceID = AVCaptureDevice.videoDevicesDictionary().keys.first
        XCTAssertNotNil(deviceID)
        
        let device = AVCaptureDevice(uniqueID: deviceID!)
        XCTAssertNotNil(device)
    }
    
    func test_that_we_can_get_a_list_of_available_audio_devices() {
        XCTAssertNotNil(AVCaptureDevice.audioDevices())
        XCTAssert(AVCaptureDevice.audioDevices().count > 0 )
        
        XCTAssertNotNil(AVCaptureDevice.audioDevicesDictionary())
        XCTAssert(AVCaptureDevice.audioDevicesDictionary().keys.count > 0)

        let deviceID = AVCaptureDevice.audioDevicesDictionary().keys.first
        XCTAssertNotNil(deviceID)

        let device = AVCaptureDevice(uniqueID: deviceID!)
        XCTAssertNotNil(device)
    }
    
    static var allTests = [
        ("test_that_we_can_get_a_list_of_available_video_devices", test_that_we_can_get_a_list_of_available_video_devices),
        ("test_that_we_can_get_a_list_of_available_audio_devices", test_that_we_can_get_a_list_of_available_audio_devices),
        ]

    
}
