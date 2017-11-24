import XCTest
@testable import Buffie

class PlaylistWriterTests: XCTestCase {
    
    func test_that_we_have_a_position_to_seek() {
        let writer = HLSLivePlayerWriter(numberOfSegments: 3)
        XCTAssertNotNil(writer.positionToSeek())
        
        XCTAssertEqual(0, writer.positionToSeek())
        _ = writer.header(with: 6)
        XCTAssertEqual(156, writer.positionToSeek())

    }
    
    func test_that_we_can_write_a_live_playlist() {
        
        let writer = HLSLivePlayerWriter(numberOfSegments: 3)
        
        var expectedOut =
"""
#EXTM3U
#EXT-X-TARGETDURATION:6
#EXT-X-VERSION:7
#EXT-X-MEDIA-SEQUENCE:0
#EXT-X-PLAYLIST-TYPE:VOD
#EXT-X-INDEPENDENT-SEGMENTS
#EXT-X-MAP:URI="fileSeq0.mp4"

"""
        XCTAssertEqual(expectedOut, writer.header(with: 6))
        
        expectedOut =
"""
#EXTINF:5.0,
file1.mp4

"""
        XCTAssertEqual(expectedOut, writer.writeSegment(with: "file1.mp4", and: 5.0))
        
        expectedOut =
"""
#EXTINF:5.0,
file1.mp4
#EXTINF:5.0,
file2.mp4

"""
        XCTAssertEqual(expectedOut, writer.writeSegment(with: "file2.mp4", and: 5.0))
        
        expectedOut =
"""
#EXTINF:5.0,
file1.mp4
#EXTINF:5.0,
file2.mp4
#EXTINF:5.0,
file3.mp4

"""
        XCTAssertEqual(expectedOut, writer.writeSegment(with: "file3.mp4", and: 5.0))

expectedOut =
"""
#EXTINF:5.0,
file2.mp4
#EXTINF:5.0,
file3.mp4
#EXTINF:5.0,
file4.mp4

"""
        XCTAssertEqual(expectedOut, writer.writeSegment(with: "file4.mp4", and: 5.0))

        
    }
    
    func test_that_we_write_the_outfile_properly() {
        
        let file   = URL(fileURLWithPath: [outputsPath, "output.m3u8"].joined(separator: "/"))
        let writer = try? HLSPlaylistWriter(file, playlistType: .live, targetDuration: 6)
        XCTAssertNotNil(writer)
        
        writer?.writerHeader()

        writer?.writeSegment(name: "file1.mp4", duration: 5.0)
        writer?.writeSegment(name: "file2.mp4", duration: 5.0)
        writer?.writeSegment(name: "file3.mp4", duration: 5.0)
        writer?.writeSegment(name: "file4.mp4", duration: 5.0)
        
        writer?.end()
        
    }
    
    
}
