//
//  ImageProcessor.swift
//  Runner
//
//  Created by Ahnaf Rahat on 14/12/23.
//

import UIKit

class ImageProcessor {
    public func getServerUrl(type: ProcessType) -> String {
        switch type {
        case .reading:
            return "https://textdetection.com.ngrok.app"
        case .object:
            return "https://yolov3-flask1-wx2bjo7cia-uc.a.run.app/debug"
        case .scene:
            return "https://supermarket.ngrok.app/scene"
//            return "https://image-792768179921.us-central1.run.app"
            //        case .bus:
            //            return "https://busfeature-wx2bjo7cia-uc.a.run.app"
        case .supermarket:
            return "https://supermarket.ngrok.app/supermarket"
        case .distance:
            return "https://yolov3-flask1-wx2bjo7cia-uc.a.run.app/depth"
        case .bus:
            return ""
        case .walking:
            return ""
        case .museum:
            return "https://ymcaimage-792768179921.us-central1.run.app"
        case .chat:
            return ""
        case .document:
            return ""
        }
    }
    
    
}
