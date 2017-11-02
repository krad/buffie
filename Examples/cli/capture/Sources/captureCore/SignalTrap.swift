import Foundation

fileprivate let note = Notification.Name("Signal Caught")

typealias Callback = () -> Void

class SignalTrap {
    
    var caughtSignal: Bool = false
    var signalID: Int32
    
    var callback: Callback?
    
    init(_ signalID: Int32, callback: Callback? = nil) {
        self.signalID = signalID
        self.callback = callback
        
        NotificationCenter.default.addObserver(forName: note,
                                               object: nil,
                                               queue: nil) {_ in
            self.caughtSignal = true
            self.callback?()
        }
        
        signal(signalID) { s in
            let notification = Notification(name: note)
            NotificationCenter.default.post(notification)
        }
    }
    
    deinit {
        
    }
    
}

