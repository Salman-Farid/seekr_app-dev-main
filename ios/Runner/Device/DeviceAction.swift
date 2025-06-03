import Foundation
import SWXMLHash

struct DeviceActionObject {
    let cmd: Int
    let status: Int

    init(cmd: Int, status: Int) {
        self.cmd = cmd
        self.status = status
    }

    static func fromXML(_ xmlData: Data) throws -> DeviceActionObject {
        let xml = XMLHash.parse(xmlData)
        let cmdElement = xml["Function"]["Cmd"].element
        let statusElement = xml["Function"]["Status"].element
        let cmdString = cmdElement?.text ?? ""
        let statusString = statusElement?.text ?? ""
        let cmd = Int(cmdString) ?? 0
        let status = Int(statusString) ?? 0
        
        return DeviceActionObject(cmd: cmd, status: status)
    }
}
