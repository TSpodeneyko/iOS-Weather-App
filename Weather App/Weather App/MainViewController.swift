//
//  MainViewController.swift
//  Weather App
//
//  Created by Timofey Spodeneyko on 25.03.2024.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {
    
    private var locationManager: CLLocationManager?
    private var currentLocation: CLLocation?
    private var currentWeatherData: CurrentWeatherAPIResponse?
    private var weeklyWeatherData: WeeklyWeatherAPIResponse?
    private lazy var weatherService = WeatherService()
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private lazy var citySearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Введите город"
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()

    private let currentWeatherStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.backgroundColor = UIColor.blur
        stackView.layer.cornerRadius = 10
        return stackView
    }()
    
    private lazy var weeklyForecastLabel: UILabel = {
        let label = UILabel()
        label.text = "Прогноз на 5 дней"
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.blueA800.cgColor, UIColor.whiteBlue20.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.3)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        return gradientLayer
    }()
    
    private lazy var currentPlaceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()
    
    private lazy var currentTempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 72)
        return label
    }()
    
    private lazy var currentWeatherDescLabel = UILabel()
    private lazy var currentTempFeelLikeLabel = UILabel()
    private lazy var currentWindSpeedLabel = UILabel()
    private lazy var currentCloudPercLabel = UILabel()
    private lazy var currentHumidityLabel = UILabel()
    private lazy var currentFallProbLabel = UILabel()

    private lazy var weeklyForecastCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.layer.cornerRadius = 10
        collectionView.register(WeeklyWeatherCollectionViewCell.self, forCellWithReuseIdentifier: WeeklyWeatherCollectionViewCell.identifier)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupLocationManager()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        gradientLayer.frame = view.bounds
    }
    
    private func setupUI() {
        view.layer.insertSublayer(gradientLayer, at: 0)
        [citySearchBar, scrollView, contentView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; view.addSubview($0) }
        scrollView.addSubview(contentView)
        [currentWeatherDescLabel, currentTempFeelLikeLabel, currentWindSpeedLabel, currentCloudPercLabel, currentHumidityLabel, currentFallProbLabel].forEach { currentWeatherStackView.addArrangedSubview($0)}
        [currentPlaceLabel, currentTempLabel, currentWeatherStackView, weeklyForecastLabel, weeklyForecastCollectionView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; contentView.addSubview($0) }
        [currentPlaceLabel, currentTempLabel, currentTempFeelLikeLabel, currentWeatherDescLabel, currentWindSpeedLabel, currentCloudPercLabel, currentHumidityLabel, currentFallProbLabel, weeklyForecastLabel].forEach { $0.textColor = .white; }
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            citySearchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            citySearchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            citySearchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            citySearchBar.heightAnchor.constraint(equalToConstant: 44),
            
            scrollView.topAnchor.constraint(equalTo: citySearchBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor),
            
            currentPlaceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
//            currentPlaceLabel.leadingAnchor.constraint(lessThanOrEqualTo: contentView.leadingAnchor, constant: 20),
//            currentPlaceLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            currentPlaceLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            currentTempLabel.topAnchor.constraint(equalTo: currentPlaceLabel.bottomAnchor, constant: 20),
            currentTempLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            currentWeatherStackView.topAnchor.constraint(equalTo: currentTempLabel.bottomAnchor, constant: 20),
            currentWeatherStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            currentWeatherStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            weeklyForecastLabel.topAnchor.constraint(equalTo: currentWeatherStackView.bottomAnchor, constant: 30),
            weeklyForecastLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            weeklyForecastCollectionView.topAnchor.constraint(equalTo: weeklyForecastLabel.bottomAnchor, constant: 20),
            weeklyForecastCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            weeklyForecastCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            weeklyForecastCollectionView.heightAnchor.constraint(equalToConstant: 420),
        ])
    }
    
    // MARK: - Methods
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
    }
    
    private func getPlaceName(location: Location, completion: @escaping (String?) -> Void) {
        let clLocation = CLLocation(latitude: location.lat, longitude: location.lon)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(clLocation) { (placemarks, error) in
            guard error == nil else {
                print("Ошибка обратного геокодирования: \(error!.localizedDescription)")
                self.showError(message: "Что-то пошло не так...\nПопробуйте зайти позже.")
                completion(nil)
                return
            }
            
            if let placemark = placemarks?.first {
                var placeNameComponents = [String]()
                if let city = placemark.locality {
                    placeNameComponents.append(city)
                }
                if let country = placemark.country {
                    placeNameComponents.append(country)
                }
                let placeName = placeNameComponents.joined(separator: ", ")
                completion(placeName)
            } else {
                self.showError(message: "Что-то пошло не так...\nПопробуйте зайти позже.")
                completion(nil)
            }
        }
    }
    
    private func getPlaceCoord(cityName: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(cityName) { (placemarks, error) in
            guard error == nil else {
                print("Ошибка геокодирования: \(error!.localizedDescription)")
                completion(nil)
                return
            }

            if let location = placemarks?.first?.location {
                completion(location.coordinate)
            } else {
                completion(nil)
            }
        }
    }
    
    private func loadWeatherData(latitude: Double, longitude: Double) {
        weatherService.fetchCurrentWeather(latitude: latitude, longitude: longitude) { [weak self] response in
            DispatchQueue.main.async {
                if let response = response {
                    self?.currentWeatherData = response
                    self?.updateCurrentWeatherDisplay(currentWeatherAPIResponse: response)
                } else {
                    self?.showError(message: "Что-то пошло не так...\nПопробуйте зайти позже.")
                }
            }
        }

        weatherService.fetchWeeklyWeather(latitude: latitude, longitude: longitude) { [weak self] response in
            DispatchQueue.main.async {
                if let response = response {
                    self?.weeklyWeatherData = response
                    self?.weeklyForecastCollectionView.reloadData()
                } else {
                    self?.showError(message: "Что-то пошло не так...\nПопробуйте зайти позже.")
                }
            }
        }
    }

    private func updateCurrentWeatherDisplay(currentWeatherAPIResponse: CurrentWeatherAPIResponse) {
        let currentWeatherData = currentWeatherAPIResponse.data
        let location = currentWeatherAPIResponse.location
        getPlaceName(location: location) { [weak self] placeName in
            DispatchQueue.main.async {
                self?.currentPlaceLabel.text = placeName ?? "Местоположение неизвестно"
            }
        }
        var roundedTemp = Int(round(currentWeatherData.values.temperature))
        var tempString: String
        if roundedTemp == 0 {
            tempString = "0"
        } else {
            tempString = "\(roundedTemp)"
        }
        currentTempLabel.text = "\(tempString) °C"
        let weatherDescription = weatherCodeDescriptions[currentWeatherData.values.weatherCode] ?? "Описание недоступно"
        currentWeatherDescLabel.text = "\(weatherDescription)"
        roundedTemp = Int(round(currentWeatherData.values.temperatureApparent))
        if roundedTemp == 0 {
            tempString = "0"
        } else {
            tempString = "\(roundedTemp)"
        }
        currentTempFeelLikeLabel.text = "Ощущается как \(tempString) °C"
        currentWindSpeedLabel.text = "Скорость ветра: \(currentWeatherData.values.windSpeed) м/с"
        currentCloudPercLabel.text = "Облачность: \(currentWeatherData.values.cloudCover) %"
        currentHumidityLabel.text = "Влажность: \(currentWeatherData.values.humidity) %"
        currentFallProbLabel.text = "Вероятность осадков: \(currentWeatherData.values.precipitationProbability) %"
    }
    
    private func showError(message: String) {
        hideAllElements(except: weeklyForecastLabel)
        self.scrollView.isScrollEnabled = false
        self.currentWeatherStackView.backgroundColor = .clear
        self.weeklyForecastLabel.textAlignment = .center
        self.weeklyForecastLabel.numberOfLines = 3
        self.weeklyForecastLabel.lineBreakMode = .byWordWrapping
        self.weeklyForecastLabel.text = message
    }
    
    private func hideAllElements(except label: UILabel) {
        let elementsToHide = [
            citySearchBar,
            currentPlaceLabel,
            currentTempLabel,
            currentWeatherStackView,
            weeklyForecastCollectionView
        ]

        for element in elementsToHide {
            element.isHidden = true
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        loadWeatherData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        locationManager?.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Ошибка получения геолокации: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager?.startUpdatingLocation()
        } else {
            print("Разрешение на доступ к геолокации не предоставлено")
        }
    }
}

// MARK: - UISearchBarDelegate
extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let cityName = searchBar.text else { return }
        getPlaceCoord(cityName: cityName) { [weak self] location in
            guard let self = self, let location = location else { return }
            self.loadWeatherData(latitude: location.latitude, longitude: location.longitude)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weeklyWeatherData?.timelines.daily.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeeklyWeatherCollectionViewCell.identifier, for: indexPath) as? WeeklyWeatherCollectionViewCell else {
            fatalError("Unable to dequeue WeeklyWeatherCollectionViewCell")
        }
        if let weatherDay = weeklyWeatherData?.timelines.daily[indexPath.row] {
            cell.configure(with: weatherDay)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
}
