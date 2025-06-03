//
//  DeviceMode.swift
//  Runner
//
//  Created by Ahnaf Rahat on 21/12/23.
//

import Foundation

public enum ProcessType {
    case reading
    case object
    case scene
    case distance
    case supermarket
    case bus
    case walking
    case museum
    case chat
    case document
}

class ProcessTypeIterator {
    static let shared = ProcessTypeIterator()

    private var processTypes: [ProcessType] =  [.document, .bus, .walking, .museum, .supermarket, .scene, .distance, .reading]
   
    private var currentIndex: Int = 0

    private init() {}

    func nextProcessType() -> ProcessType {
        guard !processTypes.isEmpty else {
            return .scene
        }

        currentIndex = (currentIndex + 1) % processTypes.count
        return processTypes[currentIndex]
    }

    func previousProcessType() -> ProcessType {
        guard !processTypes.isEmpty else {
            return .scene
        }

        currentIndex = (currentIndex - 1 + processTypes.count) % processTypes.count
        return processTypes[currentIndex]
    }
}
