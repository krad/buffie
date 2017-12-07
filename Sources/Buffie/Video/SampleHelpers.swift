import Foundation
import CoreMedia

public extension CMSampleBuffer {
    
    internal var sampleAttachments: [CFString: Any]? {
        if let buffAttach = CMSampleBufferGetSampleAttachmentsArray(self, false) as? [Any] {
            if let attachments = buffAttach.first as? [CFString: Any] {
                return attachments
            }
        }
        return nil
    }
    
    internal func attachmentValue(for key: CFString) -> Bool {
        if let dict = self.sampleAttachments {
            if let value = dict[key] as? Bool {
                return value
            }
        }
        return false
    }
    
    public var notSync: Bool {
        return self.attachmentValue(for: kCMSampleAttachmentKey_NotSync)
    }
    
    public var dependsOnOthers: Bool {
        return self.attachmentValue(for: kCMSampleAttachmentKey_DependsOnOthers)
    }
    
    public var earlierPTS: Bool {
        return self.attachmentValue(for: kCMSampleAttachmentKey_EarlierDisplayTimesAllowed)
    }
}
