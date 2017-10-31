import Buffie
import AVFoundation

class CameraOutputReader: CameraReader {

    final override func got(_ sample: CMSampleBuffer, type: SampleType) {
        super.got(sample, type: type)
        print(self.videoFormat, self.audioFormat)
    }
}

func setupCamera() {
    do {
        let cameraReader = CameraOutputReader()
        let camera       = try Camera(.back, reader: cameraReader, controlDelegate: nil)
        camera.start()
    } catch {
        print("Couldn't access camera")
    }
}


setupCamera()
while 1 == 1 { }
