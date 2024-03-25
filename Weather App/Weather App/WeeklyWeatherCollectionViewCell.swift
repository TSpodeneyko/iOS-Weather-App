//
//  WeeklyWeatherCollectionViewCell.swift
//  Weather App
//
//  Created by Timofey Spodeneyko on 25.03.2024.
//

import UIKit

class WeeklyWeatherCollectionViewCell: UICollectionViewCell {
    static let identifier = "WeeklyWeatherCollectionViewCell"

    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    private let minTempNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    private let minTempSymbolLabel: UILabel = {
        let label = UILabel()
        label.text = "°C"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()

    private let maxTempNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    private let maxTempSymbolLabel: UILabel = {
        let label = UILabel()
        label.text = "°C"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.backgroundColor = UIColor.blur
        self.layer.cornerRadius = 10
        
        [dayLabel, minTempNumberLabel, minTempSymbolLabel, maxTempNumberLabel, maxTempSymbolLabel].forEach { $0.textColor = .white; $0.translatesAutoresizingMaskIntoConstraints = false; addSubview($0) }

        NSLayoutConstraint.activate([
            dayLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),

            minTempNumberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            minTempNumberLabel.leadingAnchor.constraint(equalTo: centerXAnchor, constant: -10),

            minTempSymbolLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            minTempSymbolLabel.leadingAnchor.constraint(equalTo: minTempNumberLabel.trailingAnchor, constant: 2),

            maxTempNumberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            maxTempNumberLabel.leadingAnchor.constraint(equalTo: minTempNumberLabel.leadingAnchor, constant: 95),

            maxTempSymbolLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            maxTempSymbolLabel.leadingAnchor.constraint(equalTo: maxTempNumberLabel.trailingAnchor, constant: 2)
        ])
    }

    func configure(with weatherDay: WeekendDailyWeatherData) {
        // Определение названия дня недели и установка температур
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "ru_RU")

        if let date = formatter.date(from: weatherDay.time) {
            formatter.timeZone = TimeZone.current
            if Calendar.current.isDateInToday(date) {
                dayLabel.text = "Сегодня"
            } else {
                formatter.dateFormat = "EEEE"
                dayLabel.text = formatter.string(from: date).capitalized
            }
        } else {
            dayLabel.text = "Дата не определена"
        }

        minTempNumberLabel.text = "Мин. \(Int(weatherDay.values.temperatureMin))"
        maxTempNumberLabel.text = "Макс. \(Int(weatherDay.values.temperatureMax))"
    }
}
