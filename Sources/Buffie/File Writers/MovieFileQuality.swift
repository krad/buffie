import Foundation
import AVFoundation

public enum MovieFileQuality: String {
    case low      = "low"
    case medium   = "medium"
    case high     = "high"
    case veryhigh = "veryhight"
    case highest  = "highest"
    
    internal var settingsAssitant: AVOutputSettingsAssistant {
        switch self {
        case .highest: return AVOutputSettingsAssistant(preset: .preset3840x2160)!
        case .veryhigh: return AVOutputSettingsAssistant(preset: .preset1920x1080)!
        case .high: return AVOutputSettingsAssistant(preset: .preset1280x720)!
        case .medium: return AVOutputSettingsAssistant(preset: .preset960x540)!
        case .low: return AVOutputSettingsAssistant(preset: .preset640x480)!
        }
    }
    
    internal func videoSettings(sourceFormat: CMFormatDescription) -> [String: Any] {
        let assistant               = self.settingsAssitant
        assistant.sourceVideoFormat = sourceFormat
        return assistant.videoSettings!
    }
    
    internal func audioSettings(sourceFormat: CMFormatDescription?) -> [String: Any] {
        let assistant               = self.settingsAssitant
        assistant.sourceAudioFormat = sourceFormat
        return assistant.audioSettings!
    }
    
}

