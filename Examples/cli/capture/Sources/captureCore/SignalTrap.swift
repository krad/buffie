import Foundation

var signaled = false

struct SignalTrap {
    
    var caughtSignal: Bool {
        return signaled
    }
    
    var signalID: Int32
    
    init(_ signalID: Int32) {
        self.signalID = signalID
        
        signal(signalID, SIG_IGN)        
        signal(signalID) { s in
            
            let lock = NSLock()
            lock.lock()
            signaled = true
            lock.unlock()
        }
    }
    

}

