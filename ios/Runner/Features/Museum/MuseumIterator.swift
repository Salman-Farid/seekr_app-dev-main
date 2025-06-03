//
//  MuseumIterator.swift
//  Runner
//
//  Created by Ahnaf Rahat on 26/3/25.
//

class MuseumIterator {
    static let shared = MuseumIterator()
    
    private var museumArray: [String] = []
    private var currentIndex: Int = 0

    private init() {}

    func setMuseumArray(_ array: [String]) {
        self.museumArray = array
        self.currentIndex = 0 // Reset index when setting a new array
    }

    func nextMuseum() -> String? {
        guard !museumArray.isEmpty else { return nil }

        currentIndex = (currentIndex + 1) % museumArray.count
        return museumArray[currentIndex]
    }

    func previousMuseum() -> String? {
        guard !museumArray.isEmpty else { return nil }

        currentIndex = (currentIndex - 1 + museumArray.count) % museumArray.count
        return museumArray[currentIndex]
    }

    func getCurrentMuseum() -> String? {
        guard !museumArray.isEmpty else { return nil }
        return museumArray[currentIndex]
    }
}
