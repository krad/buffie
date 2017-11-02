import Buffie
import Dispatch
import Foundation
import AVFoundation

let version = "0.0.1"

func printUsage() {
  print("\ncapture \(version) (https://www.krad.io)")
  print("USAGE: capture <outfile> [options]\n")
  print("OPTIONS:")
  print("  -lv, --list-video: Lists available video devices on the system")
  print("  -la, --list-audio: Lists available audio devices on the system")
  print("  -cf, --container:  Set the container format {mp4, mov, m4v}.")
  print("                     (Uses the extension of outfile if this is not present.)")
  print("  -t, --time:        Recording time in seconds (Will record indefinitely if not present.) ")
  print("  -q, --quality:     Recording quality {low, medium, high}")
  print("  -b, --bitrate:     Desired bitrate ")
  print("  -f, --overwrite:   Overwrite the outfile if it exists")
  print("\nEXAMPLE:\n  capture movie.mp4 -f -time 60\n")
}

func printVideoDevices() {
    print("VIDEO:")
    for (id, name) in AVCaptureDevice.audioDevicesDictionary().enumerated() {
        print("  \(id) - \(name")
    }
}

enum CLIOptions {
case listVideoDevices
case listAudioDevices
case containerFormat(format: String)
case time(seconds: Int)
case bitrate(bytes: Int)
case overwrite

  static func parse(input: String) -> CLIOptions? {
    switch input {
    case "-lv", "--list-video":
      return CLIOptions.listVideoDevices
    case "-la", "--list-audio":
      return CLIOptions.listAudioDevices
    case "-f", "--overwrite":
      return CLIOptions.overwrite
    default:
      return nil
    }
  }

}

if CommandLine.arguments.count < 2 {
  printUsage()
  exit(0)
}


// Ignore signal interupt
signal(SIGINT, SIG_IGN)
var done = false

class CameraOutputReader: CameraReader {

    var mp4Writer: MP4Writer?
    let sigintSrc = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)

    override init() {
        super.init()
        sigintSrc.setEventHandler {
            self.mp4Writer?.stop() {
                done = true
                exit(0);
            }
        }
        sigintSrc.resume()
    }

    func setupWriter(with videoFormat: CMFormatDescription, and audioFormat: CMFormatDescription) {
        if self.mp4Writer != nil { return }

        do {
            self.mp4Writer = try MP4Writer(URL(fileURLWithPath: "hi.m4v"),
                                           videoFormat: videoFormat,
                                           audioFormat: audioFormat)
            self.mp4Writer?.start()
        }
        catch {

        }
    }

    final override func got(_ sample: CMSampleBuffer, type: SampleType) {
        super.got(sample, type: type)
        guard let videoFormat = self.videoFormat,
              let audioFormat = self.audioFormat
        else { return }

        if let fileWriter = self.mp4Writer {
            fileWriter.write(sample, type: type)
        } else {
            DispatchQueue.main.sync {
                self.setupWriter(with: videoFormat, and: audioFormat)
            }
        }
    }
}

do {
    let cameraReader = CameraOutputReader()
    let camera       = try Camera(.back, reader: cameraReader, controlDelegate: nil)
    camera.start()
} catch {
    print("Couldn't access camera")
}

while !done {
    dispatchMain()
}
