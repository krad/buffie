import Foundation
import AVFoundation

@available (macOS 10.11, *)
internal enum DisplayType {
    case active
    case drawable
}

@available (macOS 10.11, *)
public struct Display {
    
    let displayID: CGDirectDisplayID
    
    internal var input: AVCaptureScreenInput {
        return AVCaptureScreenInput(displayID: displayID)
    }
    
    public static func getAll() -> [Display] {
        let allIDs = self.getIDs(for: .active)
        return allIDs.map { Display(displayID: $0) }
    }
    
    internal static func getIDs(for displayType: DisplayType) -> [CGDirectDisplayID] {
         // If you have more than 10 screens, please send me a pic of your setup.
        let maxDisplays = 10
        var displays             = [CGDirectDisplayID](repeating: 0, count: maxDisplays)
        var displayCount: UInt32 = 0
        
        switch displayType {
        case .active:
            CGGetOnlineDisplayList(UInt32(maxDisplays), &displays, &displayCount)
        case .drawable:
            CGGetActiveDisplayList(UInt32(maxDisplays), &displays, &displayCount)
        }

        return Array(displays[0..<Int(displayCount)])
    }
    

}

public extension AVCaptureDevice {
    
    public static func videoDevices() -> [AVCaptureDevice] {
        return AVCaptureDevice.devices(for: .video)
    }
    
    public static func audioDevices() -> [AVCaptureDevice] {
        return AVCaptureDevice.devices(for: .audio)
    }
    
    public static func videoDevicesDictionary() -> [String: String] {
        return self.dictionary(for: self.videoDevices())
    }
    
    public static func audioDevicesDictionary() -> [String: String] {
        return self.dictionary(for: self.audioDevices())
    }
    
    private static func dictionary(for devices: [AVCaptureDevice]) -> [String: String] {
        var result: [String: String] = [:]
        for device in devices {
            result[device.uniqueID] = device.localizedName
        }
        return result
    }
    
    static func firstDevice(for mediaType: AVMediaType, in position: AVCaptureDevice.Position) throws -> AVCaptureDevice {
        let devices = AVCaptureDevice.devices(for: mediaType).filter { $0.position != position }
        if let device = devices.first {
            return device
        } else {
            throw CameraError.noDeviceAvailable(type: mediaType)
        }
    }
    
}
