//
//  MainViewController.swift
//  Weather App
//
//  Created by Timofey Spodeneyko on 25.03.2024.
//

import UIKit
import CoreLocation
import Network

class MainViewController: UIViewController {

    private var locationManager: CLLocationManager?
    private var currentWeatherData: CurrentWeatherAPIResponse?
    private var weeklyWeatherData: WeeklyWeatherAPIResponse?
    private let weatherService = WeatherService()

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.blueA800.cgColor, UIColor.whiteBlue20.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.3)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        return gradientLayer
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        return indicator
    }()

    private lazy var citySearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = .white
            let placeholderText = "Введите город"
            let placeholderTextColor = UIColor.white
            let placeholderAttributedString = NSAttributedString(string: placeholderText, attributes: [.foregroundColor: placeholderTextColor])
            textField.attributedPlaceholder = placeholderAttributedString

            if let leftView = textField.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = .white
            }
            searchBar.tintColor = .white

            if let clearButton = textField.value(forKey: "clearButton") as? UIButton {
                clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
                clearButton.tintColor = .white
            }
        }
        return searchBar
    }()

    private lazy var currentPlaceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()

    private let currentTempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 72)
        return label
    }()

    private let currentWeatherDescLabel = UILabel()
    private let currentTempFeelLikeLabel = UILabel()
    private let currentWindSpeedLabel = UILabel()
    private let currentCloudPercLabel = UILabel()
    private let currentHumidityLabel = UILabel()
    private let currentFallProbLabel = UILabel()

    private let currentWeatherStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.backgroundColor = UIColor.blur
        stackView.layer.cornerRadius = 10
        return stackView
    }()

    private let weeklyForecastLabel: UILabel = {
        let label = UILabel()
        label.text = "Прогноз на 5 дней"
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()

    private lazy var weeklyForecastCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
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
            citySearchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.leadingMargin),
            citySearchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: UIConstants.trailingMArgin),
            citySearchBar.heightAnchor.constraint(equalToConstant: UIConstants.searchBarHeight),

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

            currentPlaceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UIConstants.defaultMargin),
            currentPlaceLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: UIConstants.leadingMargin),
            currentPlaceLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: UIConstants.trailingMArgin),
            currentPlaceLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            currentTempLabel.topAnchor.constraint(equalTo: currentPlaceLabel.bottomAnchor, constant: UIConstants.defaultMargin),
            currentTempLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            currentWeatherStackView.topAnchor.constraint(equalTo: currentTempLabel.bottomAnchor, constant: UIConstants.defaultMargin),
            currentWeatherStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIConstants.leadingMargin),
            currentWeatherStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: UIConstants.trailingMArgin),

            weeklyForecastLabel.topAnchor.constraint(equalTo: currentWeatherStackView.bottomAnchor, constant: UIConstants.largeMargin),
            weeklyForecastLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: UIConstants.leadingMargin),
            weeklyForecastLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: UIConstants.trailingMArgin),
            weeklyForecastLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            weeklyForecastCollectionView.topAnchor.constraint(equalTo: weeklyForecastLabel.bottomAnchor, constant: UIConstants.defaultMargin),
            weeklyForecastCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIConstants.leadingMargin),
            weeklyForecastCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: UIConstants.trailingMArgin),
            weeklyForecastCollectionView.heightAnchor.constraint(equalToConstant: UIConstants.weeklyForecastCollectionViewHeight),
        ])
    }

    // MARK: - Methods
    func setupLocationManager() {
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
                CacheService.shared.saveToCache(placeName, fileName: "CurrentLocation.json")
                completion(placeName)
            } else {
                self.showError(message: "Что-то пошло не так...\nПопробуйте зайти позже.")
                completion(nil)
            }
        }
    }
    
    func getPlaceCoord(cityName: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
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
        checkInternetConnection { isConnected in
            DispatchQueue.main.async {
                if isConnected {
                    self.fetchWeatherDataFromNetwork(latitude: latitude, longitude: longitude)
                } else {
                    if let cachedWeatherData: CurrentWeatherAPIResponse = CacheService.shared.loadFromCache(fileName: "CurrentWeather.json", type: CurrentWeatherAPIResponse.self),
                       let cachedWeeklyData: WeeklyWeatherAPIResponse = CacheService.shared.loadFromCache(fileName: "WeeklyWeather.json", type: WeeklyWeatherAPIResponse.self) {
                        self.currentWeatherData = cachedWeatherData
                        self.weeklyWeatherData = cachedWeeklyData
                        self.updateCurrentWeatherDisplay(currentWeatherAPIResponse: cachedWeatherData)
                        self.weeklyForecastCollectionView.reloadData()
                        self.showAlertWith(message: "Нет соединения с интернетом, использованы последние сохраненные данные.")
                    } else {
                        self.showError(message: "Нет соединения с интернетом и нет кешированных данных.")
                    }
                }
            }
        }
    }

    private func fetchWeatherDataFromNetwork(latitude: Double, longitude: Double) {
        weatherService.fetchCurrentWeather(latitude: latitude, longitude: longitude) { [weak self] response in
            DispatchQueue.main.async {
                if let response = response {
                    self?.currentWeatherData = response
                    self?.updateCurrentWeatherDisplay(currentWeatherAPIResponse: response)
                    CacheService.shared.saveToCache(response, fileName: "CurrentWeather.json")
                } else {
                    self?.showError(message: "Не удалось обновить текущий прогноз.\nПопробуйте зайти позже.")
                }
            }
        }

        weatherService.fetchWeeklyWeather(latitude: latitude, longitude: longitude) { [weak self] response in
            DispatchQueue.main.async {
                if let response = response {
                    self?.weeklyWeatherData = response
                    self?.weeklyForecastCollectionView.reloadData()
                    CacheService.shared.saveToCache(response, fileName: "WeeklyWeather.json")
                } else {
                    self?.showError(message: "Не удалось обновить недельный прогноз.\nПопробуйте зайти позже.")
                }
            }
        }
    }

    private func updateCurrentWeatherDisplay(currentWeatherAPIResponse: CurrentWeatherAPIResponse) {
        let currentWeatherData = currentWeatherAPIResponse.data
        checkInternetConnection { isConnected in
            DispatchQueue.main.async {
                if isConnected {
                    let location = currentWeatherAPIResponse.location
                    self.getPlaceName(location: location) { [weak self] placeName in
                        self?.currentPlaceLabel.text = placeName ?? "Местоположение неизвестно"
                    }
                } else {
                    self.currentPlaceLabel.text = CacheService.shared.loadFromCache(fileName: "CurrentLocation.json", type: String.self)
                }
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

    func checkInternetConnection(completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                completion(true)
            } else {
                completion(false)
            }
            monitor.cancel()
        }

        let queue = DispatchQueue.global(qos: .background)
        monitor.start(queue: queue)
    }

    func showLoadingIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }

    private func showAlertWith(message: String) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }

    private func showError(message: String) {
        hideAllElements(except: weeklyForecastLabel)
        self.scrollView.isScrollEnabled = false
        self.currentWeatherStackView.backgroundColor = .clear
        self.weeklyForecastLabel.textAlignment = .center
        self.weeklyForecastLabel.numberOfLines = 4
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
        self.showLoadingIndicator()
        self.checkInternetConnection { isConnected in
            DispatchQueue.main.async {
                if isConnected {
                    self.getPlaceCoord(cityName: cityName) { [weak self] location in
                        guard let self = self, let location = location else {
                            self?.hideLoadingIndicator()
                            self?.showAlertWith(message: "Город не найден. Проверьте правильность написания и повторите попытку.")
                            return
                        }
                        self.hideLoadingIndicator()
                        self.loadWeatherData(latitude: location.latitude, longitude: location.longitude)
                    }
                } else {
                    self.hideLoadingIndicator()
                    self.showAlertWith(message: "Нет соединения с интернетом.")
                }
            }
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
        return CGSize(width: collectionView.frame.width, height: UIConstants.weeklyForecastCollectionViewCellHeight)
    }
}
