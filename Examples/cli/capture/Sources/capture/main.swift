import Buffie

class CameraOutputReader: CameraReader {

    final func got(_ sample: CMSampleBuffer, type: SampleType) {
        print(sample, type)
    }
}

@available(macOS 10.11, iOS 5, *)
func setupCamera() {
    do {
        let cameraReader = CameraOutputReader()
        let camera       = try Camera(.back, reader: cameraReader, controlDelegate: nil)
        camera.start()
    } catch {
        print("Couldn't access camera")
    }
}


if #available(macOS 10.11, iOS 5, *) {
    setupCamera()
    while 1 == 1 { }
} else {
    print("Could not setup camera")
}
