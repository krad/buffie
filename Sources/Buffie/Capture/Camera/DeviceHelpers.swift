import Foundation
import AVFoundation

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

public extension AVCaptureDeviceInput {
    
    public static func input(for deviceID: String?) throws -> AVCaptureDeviceInput? {
        if let devID = deviceID {
            if let device = AVCaptureDevice(uniqueID: devID) {
                return try AVCaptureDeviceInput(device: device)
            } else {
                throw CameraError.deviceNotFound(deviceID: devID)
            }
        }
        return nil
    }
    
}
