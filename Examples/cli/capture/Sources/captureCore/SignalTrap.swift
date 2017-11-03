import Foundation

class SignalTrap {
    
    var signalID: Int32
    var signalSource: DispatchSourceSignal
    var callback: () -> Void
    
    
    init(_ signalID: Int32, onTrap: @escaping () -> Void) {
        self.signalID = signalID
        self.callback = onTrap
        
        signal(signalID, SIG_IGN)
        
        self.signalSource = DispatchSource.makeSignalSource(signal: signalID, queue: .main)
        self.signalSource.setEventHandler {
            self.callback()
        }
        self.signalSource.resume()
    }
    

}
