//
//  WeatherService.swift
//  Weather App
//
//  Created by Timofey Spodeneyko on 25.03.2024.
//

import Foundation

private let apiKey = "gXqWiaMouQgbMaDt6ZpxLEe5lmrFGHLv"

class WeatherService {
    func fetchCurrentWeather(latitude: Double, longitude: Double, completion: @escaping (CurrentWeatherAPIResponse?) -> Void) {
        let urlString = "https://api.tomorrow.io/v4/weather/realtime?location=\(latitude),\(longitude)&apikey=\(apiKey)"
        performRequest(urlString: urlString, responseType: CurrentWeatherAPIResponse.self, completion: completion)
    }

    func fetchWeeklyWeather(latitude: Double, longitude: Double, completion: @escaping (WeeklyWeatherAPIResponse?) -> Void) {
        let urlString = "https://api.tomorrow.io/v4/weather/forecast?location=\(latitude),\(longitude)&units=metric&timesteps=daily&apikey=\(apiKey)"
        performRequest(urlString: urlString, responseType: WeeklyWeatherAPIResponse.self, completion: completion)
    }

    private func performRequest<T: Decodable>(urlString: String, responseType: T.Type, completion: @escaping (T?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["accept": "application/json"]
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let response = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(response)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        dataTask.resume()
    }
}
