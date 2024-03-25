//
//  WeatherData.swift
//  Weather App
//
//  Created by Timofey Spodeneyko on 25.03.2024.
//

import Foundation

struct CurrentWeatherAPIResponse: Decodable {
    let data: CurrentWeatherData
    let location: Location
}

struct CurrentWeatherData: Decodable {
    let time: String
    let values: CurrentWeatherValues
}

struct CurrentWeatherValues: Decodable {
    let cloudCover: Int
    let humidity: Int
    let precipitationProbability: Int
    let temperature: Double
    let temperatureApparent: Double
    let uvIndex: Int
    let visibility: Double
    let weatherCode: Int
    let windDirection: Double
    let windSpeed: Double
}

struct Location: Decodable {
    let lat: Double
    let lon: Double
}

struct WeeklyWeatherAPIResponse: Decodable {
    let timelines: Timelines
    let location: Location
}

struct Timelines: Decodable {
    let daily: [WeekendDailyWeatherData]
}

struct WeekendDailyWeatherData: Decodable {
    let time: String
    let values: WeeklyWeatherValues
}

struct WeeklyWeatherValues: Decodable {
    let temperatureAvg: Double
    let temperatureMin: Double
    let temperatureMax: Double
}

let weatherCodeDescriptions: [Int: String] = [
    0: "Неизвестно",
    1000: "Ясно, солнечно",
    1001: "Облачно",
    1100: "Преимущественно ясно",
    1101: "Переменная облачность",
    1102: "Переменная облачность",
    2000: "Туман",
    2100: "Легкий туман",
    4000: "Морось",
    4001: "Дождь",
    4200: "Легкий дождь",
    4201: "Сильный дождь",
    5000: "Снег",
    5001: "Снегопад",
    5100: "Лёгкий снег",
    5101: "Сильный снег",
    6000: "Замерзающая морось",
    6001: "Ледяной дождь",
    6200: "Лёгкий ледяной дождь",
    6201: "Сильный ледяной дождь",
    7000: "Град",
    7101: "Сильный град",
    7102: "Лёгкий град",
    8000: "Гроза"
]
