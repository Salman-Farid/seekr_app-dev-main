//
//  MuseumMode.swift
//  Runner
//
//  Created by Ahnaf Rahat on 31/5/25.
//

import Foundation

class MuseumMode{
    static let shared = MuseumMode()
    
    private init() {}
    
    var museumArray: [String] = []
    
    func fetchMuseumList(completion: @escaping ([String]?) -> Void) {
        let urlString = "https://ymcaimage-792768179921.us-central1.run.app/museumlist"
        guard let url = URL(string: urlString) else { 
            completion(nil)
            return 
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            do {
                let museumList = try JSONDecoder().decode([String].self, from: data)
                print("Museum List:", museumList) // Debugging purpose
                DispatchQueue.main.async {
                    self.museumArray = museumList // Save response to local variable
                    MuseumIterator.shared.setMuseumArray(museumList)
                    completion(museumList)
                }
            } catch {
                print("Error decoding JSON:", error)
                completion(nil)
            }
        }
        
        task.resume()
    }
}
