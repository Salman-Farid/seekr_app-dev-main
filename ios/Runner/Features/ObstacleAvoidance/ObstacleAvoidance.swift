//
//  ObstacleAvoidance.swift
//  Runner
//
//  Created by Ahnaf Rahat on 15/2/25.
//



import UIKit
import Vision
import CoreML

struct ObjectSize {
    let height: CGFloat
    let width: CGFloat
}


struct ObjectData {
    let object: String
    let distance: Int
    let location: String
}

class DepthEstimator {
    func distanceEstimation(origHeight: CGFloat, imgHeight: CGFloat) -> Int {
        var distance = (3.543 * 100 * origHeight) / imgHeight
        if distance <= 1 {
            return 1
        } else if distance <= 2 {
            return 2
        } else {
            return 3
        }
    }
    
    func dotProduct(vA: [CGFloat], vB: [CGFloat]) -> CGFloat {
        return vA[0] * vB[0] + vA[1] * vB[1]
    }
    
    func angleClock(angle: Int) -> String {
        switch angle {
        case 0...30:
            return "1'o clock"
        case 31...60:
            return "2'o clock"
        case 61...90:
            return "3'o clock"
        case 270...300:
            return "9'o clock"
        case 301...330:
            return "10'o clock"
        case 331...360:
            return "11'o clock"
        default:
            return "12'o clock"
        }
    }
    
    func objectLocationClockAngle(lineA: [[CGFloat]], lineB: [[CGFloat]], position: String) -> String {
        let vA = [lineA[0][0] - lineA[1][0], lineA[0][1] - lineA[1][1]]
        let vB = [lineB[0][0] - lineB[1][0], lineB[0][1] - lineB[1][1]]
        
        let dotProd = dotProduct(vA: vA, vB: vB)
        let magA = sqrt(dotProduct(vA: vA, vB: vA))
        let magB = sqrt(dotProduct(vA: vB, vB: vB))
        
        let cosValue = dotProd / (magA * magB)
        let angleRadians = acos(cosValue)
        let angleDegrees = Int(round(angleRadians * 180 / .pi).truncatingRemainder(dividingBy: 360))

        if position == "right" {
            return angleClock(angle: angleDegrees)
        } else if position == "left" {
            return angleClock(angle: 360 - angleDegrees)
        } else {
            return "12'o clock"
        }
    }
    
    func objectPosition(imgWidth: CGFloat, xCenter: CGFloat) -> String {
        if xCenter >= imgWidth - (imgWidth * 0.3) {
            return "right"
        } else if xCenter <= imgWidth * 0.3 {
            return "left"
        } else {
            return "straight"
        }
    }
    
    func depthEstimation(image: UIImage, predData: [[CGFloat]], classNames: [String], objHeightWidth: [String: (CGFloat, CGFloat)], mode: String) -> [ObjectData] {
        var distPosList: [ObjectData] = []
        let imgWidth = image.size.width
        let imgHeight = image.size.height
//        print("objHeightWidth__________depthEstimation________\(objHeightWidth)")
//        print("objHeightWidth__________depthEstimation________\(objHeightWidth["cake"])")
//        print("objHeightWidth__________depthEstimation________\(objHeightWidth["car"]?.0)")


        for data in predData {
            let x1 = data[0], y1 = data[1], x2 = data[2], y2 = data[3]
            let classID = Int(data[5])
            let category : String = classNames[classID]
            
            let heightObj = abs(y1 - y2)
            let widthObj = abs(x2 - x1)
            let centerX = x1 + widthObj / 2
            let centerY = y2 - heightObj / 2
            
            let lineA = [[imgWidth / 2, 0], [imgWidth / 2, imgHeight]]
            let lineB = [[imgWidth / 2, 0], [centerX, centerY]]
            let position = objectPosition(imgWidth: imgWidth, xCenter: centerX)
            let location = objectLocationClockAngle(lineA: lineA, lineB: lineB, position: position)
            
            print("Category___and__classid\(category)____\(classID)")
            print("origHeight\(objHeightWidth[category]?.0)___and__imgHeight\(heightObj)")
            let estimatedDistance = distanceEstimation(origHeight: objHeightWidth[category]?.0 ?? 1, imgHeight: heightObj)
            
            if estimatedDistance <= 3 {
                if mode == "depth estimation" || (mode == "obstacle avoidance" && position == "straight") {
                    let objectData = ObjectData(object: category, distance: estimatedDistance, location: location)
                    distPosList.append(objectData)
                }
            }
        }
        return distPosList
    }
}

class DistanceEstimator {
    private let focalLength: CGFloat = 700.0
    let knownObjectSizes: [String: ObjectSize] = [
        "person": ObjectSize(height: 1.7, width: 0.367),
        "bicycle": ObjectSize(height: 1.676, width: 0.54),
        "car": ObjectSize(height: 1.828, width: 1.767),
        "motorbike": ObjectSize(height: 1.524, width: 1.016),
        "aeroplane": ObjectSize(height: 84.8, width: 88.4),
        "bus": ObjectSize(height: 3.81, width: 2.55),
        "train": ObjectSize(height: 4.025, width: 3.24),
        "truck": ObjectSize(height: 1.94, width: 2.049),
        "boat": ObjectSize(height: 0.46, width: 3.05),
        "traffic light": ObjectSize(height: 0.762, width: 0.241),
        "fire hydrant": ObjectSize(height: 0.762, width: 0.355),
        "stop sign": ObjectSize(height: 3.05, width: 0.5),
        "parking meter": ObjectSize(height: 0.5, width: 0.2),
        "bench": ObjectSize(height: 0.508, width: 0.381),
        "bird": ObjectSize(height: 0.47, width: 0.35),
        "cat": ObjectSize(height: 0.46, width: 0.64),
        "dog": ObjectSize(height: 0.84, width: 1.07),
        "horse": ObjectSize(height: 1.73, width: 1.9),
        "sheep": ObjectSize(height: 1.17, width: 1.27),
        "cow": ObjectSize(height: 1.8, width: 2.45),
        "elephant": ObjectSize(height: 4.0, width: 5.0),
        "bear": ObjectSize(height: 1.37, width: 2.44),
        "zebra": ObjectSize(height: 1.91, width: 2.44),
        "giraffe": ObjectSize(height: 6.0, width: 2.6),
        "backpack": ObjectSize(height: 0.47, width: 0.23),
        "umbrella": ObjectSize(height: 1.01, width: 1.3),
        "handbag": ObjectSize(height: 0.23, width: 0.26),
        "tie": ObjectSize(height: 0.508, width: 0.1),
        "suitcase": ObjectSize(height: 0.56, width: 0.38),
        "frisbee": ObjectSize(height: 0.3, width: 0.3),
        "skis": ObjectSize(height: 1.58, width: 0.2),
        "snowboard": ObjectSize(height: 1.35, width: 0.2),
        "sports ball": ObjectSize(height: 0.23, width: 0.23),
        "kite": ObjectSize(height: 0.9, width: 0.8),
        "baseball bat": ObjectSize(height: 0.02, width: 0.864),
        "baseball glove": ObjectSize(height: 0.3, width: 0.24),
        "skateboard": ObjectSize(height: 0.0889, width: 0.1905),
        "surfboard": ObjectSize(height: 2.194, width: 0.56),
        "tennis racket": ObjectSize(height: 0.6096, width: 0.257),
        "bottle": ObjectSize(height: 0.304, width: 0.081),
        "wine glass": ObjectSize(height: 0.155, width: 0.065),
        "cup": ObjectSize(height: 0.094, width: 0.08),
        "fork": ObjectSize(height: 0.18, width: 0.1),
        "knife": ObjectSize(height: 0.152, width: 0.044),
        "spoon": ObjectSize(height: 0.16, width: 0.036),
        "bowl": ObjectSize(height: 0.1, width: 0.3),
        "banana": ObjectSize(height: 0.18, width: 0.03),
        "apple": ObjectSize(height: 0.02, width: 0.02),
        "sandwich": ObjectSize(height: 0.121, width: 0.121),
        "orange": ObjectSize(height: 0.02, width: 0.02),
        "broccoli": ObjectSize(height: 0.121, width: 0.121),
        "carrot": ObjectSize(height: 0.18, width: 0.09),
        "hot dog": ObjectSize(height: 0.18, width: 0.09),
        "pizza": ObjectSize(height: 0.02, width: 0.406),
        "donut": ObjectSize(height: 0.0762, width: 0.2),
        "cake": ObjectSize(height: 0.12, width: 0.4),
        "chair": ObjectSize(height: 1.009, width: 0.485),
        "sofa": ObjectSize(height: 0.84, width: 1.52),
        "potted plant": ObjectSize(height: 1.05, width: 0.28),
        "bed": ObjectSize(height: 0.75, width: 0.46),
        "dining table": ObjectSize(height: 0.787, width: 1.016),
        "toilet": ObjectSize(height: 0.762, width: 0.735),
        "tv monitor": ObjectSize(height: 0.34, width: 0.556),
        "laptop": ObjectSize(height: 0.209, width: 0.35),
        "mouse": ObjectSize(height: 0.0381, width: 0.0855),
        "remote": ObjectSize(height: 0.17, width: 0.035),
        "keyboard": ObjectSize(height: 0.022, width: 0.022),
        "cell phone": ObjectSize(height: 0.1436, width: 0.0709),
        "microwave": ObjectSize(height: 0.313, width: 0.52),
        "oven": ObjectSize(height: 0.72, width: 0.76),
        "toaster": ObjectSize(height: 0.284, width: 0.345),
        "sink": ObjectSize(height: 0.75, width: 0.61),
        "refrigerator": ObjectSize(height: 1.82, width: 0.749),
        "book": ObjectSize(height: 0.215, width: 0.139),
        "clock": ObjectSize(height: 0.3, width: 0.3),
        "vase": ObjectSize(height: 0.4, width: 0.1),
        "scissors": ObjectSize(height: 0.1778, width: 0.1),
        "teddy bear": ObjectSize(height: 0.304, width: 0.33),
        "hair drier": ObjectSize(height: 0.28, width: 0.245),
        "toothbrush": ObjectSize(height: 0.166, width: 0.0063),
        "MTR sign": ObjectSize(height: 0.5, width: 0.3),
        "EXIT sign": ObjectSize(height: 0.5, width: 0.2),
        "Red taxi": ObjectSize(height: 1.8, width: 1.5),
        "Dustbin": ObjectSize(height: 0.4, width: 0.8),
        "Customer service sign": ObjectSize(height: 0.6, width: 0.3),
        "Bus Stops": ObjectSize(height: 2.0, width: 2.55),
        "Elevator Buttons": ObjectSize(height: 0.3, width: 0.18),
        "Minibus Stops": ObjectSize(height: 2.0, width: 0.55),
        "Minibus": ObjectSize(height: 2.67, width: 2.24),
        "Traffic Cones": ObjectSize(height: 0.5, width: 0.2)
    ]
    
    func estimateDistance(objectType: String, perceivedHeight: CGFloat) -> CGFloat? {
        guard let objectSize = knownObjectSizes[objectType] else {
            return nil
        }
        return (objectSize.height * focalLength) / perceivedHeight
    }
}
