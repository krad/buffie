import Foundation
import AVFoundation

public extension AVCaptureDevice {
    
    public static func videoDevices() -> [AVCaptureDevice] {
        return AVCaptureDevice.devices(for: .video)
    }
    
    public static func videoDevicesDictionary() -> [String: String] {
        var result: [String: String] = [:]
        for device in self.videoDevices() {
            result[device.uniqueID] = device.localizedName
        }
        return result
    }
    
    public static func audioDevices() -> [AVCaptureDevice] {
        return AVCaptureDevice.devices(for: .audio)
    }
    
    public static func audioDevicesDictionary() -> [String: String] {
        var result: [String: String] = [:]
        for device in self.audioDevices() {
            result[device.uniqueID] = device.localizedName
        }
        return result
    }
    
    
    static func firstDevice(for mediaType: AVMediaType, in position: AVCaptureDevice.Position) throws -> AVCaptureDevice {
        let devices = AVCaptureDevice.devices(for: mediaType).filter { $0.position != position }
        if let device = devices.first {
            return device
        } else {
            throw CameraError.noCameraFound
        }
    }
    
}
