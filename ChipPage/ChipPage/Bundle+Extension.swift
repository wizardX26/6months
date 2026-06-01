//
//  Bundle+Extension.swift
//  ChipPage
//
//  Created by wizard.os25 on 1/6/26.
//

import Foundation

extension Bundle {
    
    func decode<T: Decodable>(
        _ type: T.Type,
        from fileName: String
    ) -> T {
        
        guard let url = url(forResource: fileName, withExtension: "json") else {
            fatalError("Missing \(fileName).json")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Cannot load \(fileName).json")
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            fatalError("Decode failed: \(error)")
        }
    }
}
