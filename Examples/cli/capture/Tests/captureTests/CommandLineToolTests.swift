import XCTest
@testable import captureCore

class CommandLineToolTests: XCTestCase {

    func test_that_we_can_parse_output_args() {
        let dir = #file.components(separatedBy: "/").dropLast(3).joined(separator: "/")
        let args = ["./capture", "-o", "movie.mp4"]
        let tool = try? CommandLineTool(args)
        XCTAssertNotNil(tool)
        XCTAssertEqual(tool?.url?.absoluteString, "file://\(dir)/movie.mp4")
        XCTAssertEqual(tool?.container, .mp4)
        XCTAssertNil(tool?.time)
    }
    
    func test_that_we_can_parse_time_args() {
        let args = ["./capture", "-o", "movie.mp4", "-t", "60"]
        let tool = try? CommandLineTool(args)
        XCTAssertNotNil(tool)
        XCTAssertNotNil(tool?.url)
        XCTAssertNotNil(tool?.container)
        XCTAssertNotNil(tool?.time)
    }
    
    func test_that_we_can_parse_simple_outputs() {
        let args = ["./capture", "-l"]
        let tool = try? CommandLineTool(args)
        XCTAssertNotNil(tool)
        XCTAssertEqual(tool?.helpOptions, .printVideoInputs)
        
        let args2 = ["./capture", "-w"]
        let tool2 = try? CommandLineTool(args2)
        XCTAssertNotNil(tool2)
        XCTAssertEqual(tool2?.helpOptions, .printAudioInputs)

        let args3 = ["./capture", "-l", "-w"]
        let tool3 = try? CommandLineTool(args3)
        XCTAssertNotNil(tool3)
        XCTAssertEqual(tool3?.helpOptions, [.printVideoInputs, .printAudioInputs])

    }
    
    func test_that_we_can_parse_the_container() {
        let args = ["./capture", "-o", "movie", "-c", "mov"]
        let tool = try? CommandLineTool(args)
        XCTAssertNotNil(tool)
        XCTAssertNotNil(tool?.url)
        XCTAssertEqual(tool?.container, .mov)
    }
    
    func test_that_we_can_parse_quality() {
        let args = ["./capture", "-o", "movie", "-c", "mov", "-q", "low"]
        let tool = try? CommandLineTool(args)
        XCTAssertNotNil(tool)
        XCTAssertEqual(tool?.quality, .low)
    }
    
    func test_that_we_can_parse_bitrate() {
        let args = ["./capture", "-o", "movie.mp4", "-b", "250000"]
        let tool = try? CommandLineTool(args)
        XCTAssertNotNil(tool)
        XCTAssertEqual(250000, tool?.bitrate)
    }

    func test_that_we_can_force_overwrite() {
        let args = ["./capture", "-o", "movie.mp4", "-f"]
        let tool = try? CommandLineTool(args)
        XCTAssertNotNil(tool)
        XCTAssertTrue(tool!.forceOverwrite)
    }
    
    func test_that_we_can_choose_a_video_and_audio_device_to_use() {
        let args = ["./capture", "-o", "movie.mp4", "-v", "video123", "-a", "audio123"]
        let tool = try? CommandLineTool(args)
        XCTAssertNotNil(tool)
        XCTAssertNotNil(tool?.videoDeviceID)
        XCTAssertNotNil(tool?.audioDeviceID)
        
    }

}

