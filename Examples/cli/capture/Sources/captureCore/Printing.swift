import Foundation
import Buffie
import AVFoundation

let version = "0.0.1"

public func printUsage() {
    print("\ncapture \(version) (https://www.krad.io)")
    print("USAGE: capture [options]\n")
    print("OPTIONS:")
    print("  -o:\tPath to file where video should be written")
    print("  -l:\tLists available video devices on the system")
    print("  -v:\tVideo device to record from (use -l to get list of available devices.)")
    print("  -w:\tLists available audio devices on the system")
    print("  -a:\tAudio device to record from (use -w to get a list of available devices.)")
    print("  -c:\tSet the container format {mp4, mov, m4v}.")
    print("     \tUses the extension of outfile if this is not present.\n")
    print("  -t:\tRecording time in seconds")
    print("     \tWill record indefinitely if not present.\n")
    print("  -q:\tRecording quality {low, medium, high}")
    print("  -b:\tDesired bitrate")
    print("  -f:\tOverwrite the outfile if it exists")
    print("\nEXAMPLE:\n  capture -o movie.mp4 -f -t 60\n")
}

public func printVideoDevices() {
    print("VIDEO:")
    for (id, name) in AVCaptureDevice.videoDevicesDictionary() {
        print("  \(id) - \(name)")
    }
    print("")
}

public func printAudioDevices() {
    print("AUDIO:")
    for (id, name) in AVCaptureDevice.audioDevicesDictionary() {
        print("  \(id) - \(name)")
    }
    print("")
}
