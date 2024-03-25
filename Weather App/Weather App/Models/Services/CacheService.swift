//
//  CacheService.swift
//  Weather App
//
//  Created by Timofey Spodeneyko on 25.03.2024.
//

import Foundation
import CoreLocation

class CacheService {
    static let shared = CacheService()

    private let fileManager = FileManager.default

    private func cacheURL(for fileName: String) -> URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName)
    }

    func saveToCache<T: Encodable>(_ data: T, fileName: String) {
        guard let url = cacheURL(for: fileName) else { return }
        do {
            let encodedData = try JSONEncoder().encode(data)
            try encodedData.write(to: url)
        } catch {
            print("Ошибка кеширования данных: \(error)")
        }
    }

    func loadFromCache<T: Decodable>(fileName: String, type: T.Type) -> T? {
        guard let url = cacheURL(for: fileName) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Ошибка получения кешированных данных: \(error)")
            return nil
        }
    }

    func shouldUseCachedData(currentLocation: CLLocation, lastLocation: CLLocation?, maxDistance: Double = 1000) -> Bool {
        guard let lastLocation = lastLocation else { return true }
        return currentLocation.distance(from: lastLocation) < maxDistance
    }
}
