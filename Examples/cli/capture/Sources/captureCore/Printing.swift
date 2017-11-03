import Foundation
import Buffie
import AVFoundation

let version = "0.0.1"

internal func printProgramInfo() {
    print("\ncapture \(version) (https://www.krad.io)")
}

public func printUsage() {
    printProgramInfo()
    print("USAGE: capture [options]\n")
    print("OPTIONS:")
    print("  -o:\tPath to file where video should be written")
    print("  -l:\tLists available video devices on the system")
    print("  -v:\tVideo device to record from (use -l to get list of available devices.)")
    print("     \t(Uses first available device if not given)")
    print("  -w:\tLists available audio devices on the system")
    print("     \t(Uses first available device if not given)")
    print("  -a:\tAudio device to record from (use -w to get a list of available devices.)")
    print("  -c:\tSet the container format {mp4, mov, m4v}.")
    print("     \tUses the extension of outfile if this is not present.\n")
    print("  -t:\tRecording time in seconds")
    print("     \tWill record indefinitely if not present.\n")
    print("  -q:\tRecording quality {low, medium, high, veryhigh, highest}")
    print("  -b:\tDesired bitrate")
    print("  -f:\tOverwrite the outfile if it exists")
    print("\nEXAMPLE:\n  capture -o movie.mp4 -f -t 60\n")
}

public func printRunningMessage() {
    printProgramInfo()
    print("Recording.  Press Ctrl-C to finish")
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
