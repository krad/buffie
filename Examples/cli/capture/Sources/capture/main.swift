import Buffie


class MuxerDelegate: AVMuxerDelegate {
    
    func got(paramSet: [[UInt8]]) {
        print(#function, paramSet)
    }
    
    func muxed(data: [UInt8]) {
        print(#function)
    }
}

@available(macOS 10.11, iOS 5, *)
func setupCamera() {
    do {
        let muxerDelegate = MuxerDelegate()
        let muxer         = try AVMuxer(delegate: muxerDelegate)
        let camera        = try Camera(.back, reader: muxer, controlDelegate: nil)
        camera.start()
    } catch {
        print("Couldn't access camera")
    }
}


if #available(macOS 10.11, iOS 5, *) {
    setupCamera()
} else {
    print("Could not setup camera")
}
