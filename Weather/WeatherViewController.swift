//
//  WeatherViewController.swift
//  Weather
//
//  Created by Peter Bassem on 7/23/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import CoreLocation

// Get User Location: CoreLocation
// List Temprature: TableView
// Show Houlry Temprature For today: Custom Cell with CollectionView
// API / Request to get the data

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var tempratureTableView: UITableView!
    
    var models = [DailyWeatherEntry]()
    var hourlyModels = [HourlyWeatherEntry]()
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var currentWeather: CurrentWeather?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(red: 52/255, green: 109/255, blue: 179/255, alpha: 1)
        // Register 2 cells
        tempratureTableView.backgroundColor = UIColor(red: 52/255, green: 109/255, blue: 179/255, alpha: 1)
        tempratureTableView.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
        tempratureTableView.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
        tempratureTableView.delegate = self
        tempratureTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupLocation()
    }
    
    func requestWeatherForLocation() {
        guard let long = currentLocation?.coordinate.longitude, let lat = currentLocation?.coordinate.latitude else { return }
        
        let url = "https://api.darksky.net/forecast/ddcc4ebb2a7c9930b90d9e59bda0ba7a/\(lat),\(long)?exclude=[flags,minutely]"
        URLSession.shared.dataTask(with: URL(string: url)!) { [weak self] (data, _, error) in
            guard let data = data, error == nil else {
                print("something went worng:", error!)
                return
            }
            var json: WeatherResponse?
            do {
                json = try JSONDecoder().decode(WeatherResponse.self, from: data)
            } catch let error {
                print("Error decoding model:", error)
            }
            
            guard let result = json else { return }
            let entries = result.daily.data
            self?.models.append(contentsOf: entries)
            let current = result.currently
            self?.currentWeather = current
            
            self?.hourlyModels = result.hourly.data
            
            DispatchQueue.main.async {
                self?.tempratureTableView.reloadData()
                self?.tempratureTableView.tableHeaderView = self?.createTableHeader()
            }
            
        }.resume()
    }
    
    private func createTableHeader() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width))
        
        headerView.backgroundColor = UIColor(red: 52/255, green: 109/255, blue: 179/255, alpha: 1)
        
        let locationLabel = UILabel(frame: CGRect(x: 10, y: 10, width: (view.frame.size.width - 20), height: (headerView.frame.size.height / 5)))
        let summaryLabel = UILabel(frame: CGRect(x: 10, y: (locationLabel.frame.size.height + 20), width: (view.frame.size.width - 20), height: (headerView.frame.size.height / 5)))
        let tempLabel = UILabel(frame: CGRect(x: 10, y: (summaryLabel.frame.size.height + locationLabel.frame.size.height + 20), width: (view.frame.size.width - 20), height: (headerView.frame.size.height / 3)))
        
        headerView.addSubview(locationLabel)
        headerView.addSubview(summaryLabel)
        headerView.addSubview(tempLabel)
        
        [summaryLabel, locationLabel, tempLabel].forEach { $0.textAlignment = .center }
        
        locationLabel.text = "Current Location"
        
        tempLabel.text = String(self.currentWeather?.temperature ?? 0.0) + "°"
        tempLabel.font = UIFont(name: "Helvetica-Bold", size: 32)
        summaryLabel.text = self.currentWeather?.summary
        
        return headerView
    }
}

//MARK: - Location
extension WeatherViewController: CLLocationManagerDelegate {
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            requestWeatherForLocation()
        }
    }
}

//MARK: - UITableView
extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tempratureTableView.dequeueReusableCell(withIdentifier: HourlyTableViewCell.identifier, for: indexPath) as! HourlyTableViewCell
            cell.configure(with: hourlyModels)
            return cell
        }
        let cell = tempratureTableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
        cell.configure(with: models[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

struct WeatherResponse: Codable {
    let latitude: Float
    let longitude: Float
    let timezone: String
    let currently: CurrentWeather
    let hourly: HourlyWeather
    let daily: DailyWeather
    let offset: Float
}

struct CurrentWeather: Codable {
    let time: Int
    let summary: String
    let icon: String
    let nearestStormDistance: Int
    let nearestStormBearing: Int
    let precipIntensity: Int
    let precipProbability: Int
    let temperature: Double
    let apparentTemperature: Double
    let dewPoint: Double
    let humidity: Double
    let pressure: Double
    let windSpeed: Double
    let windGust: Double
    let windBearing: Int
    let cloudCover: Double
    let uvIndex: Int
    let visibility: Double
    let ozone: Double
}

struct DailyWeather: Codable {
    let summary: String
    let icon: String
    let data: [DailyWeatherEntry]
}

struct DailyWeatherEntry: Codable {
    let time: Int
    let summary: String
    let icon: String
    let sunriseTime: Int
    let sunsetTime: Int
    let moonPhase: Double
    let precipIntensity: Float
    let precipIntensityMax: Float
    let precipIntensityMaxTime: Int
    let precipProbability: Double
    let precipType: String?
    let temperatureHigh: Double
    let temperatureHighTime: Int
    let temperatureLow: Double
    let temperatureLowTime: Int
    let apparentTemperatureHigh: Double
    let apparentTemperatureHighTime: Int
    let apparentTemperatureLow: Double
    let apparentTemperatureLowTime: Int
    let dewPoint: Double
    let humidity: Double
    let pressure: Double
    let windSpeed: Double
    let windGust: Double
    let windGustTime: Int
    let windBearing: Int
    let cloudCover: Double
    let uvIndex: Int
    let uvIndexTime: Int
    let visibility: Double
    let ozone: Double
    let temperatureMin: Double
    let temperatureMinTime: Int
    let temperatureMax: Double
    let temperatureMaxTime: Int
    let apparentTemperatureMin: Double
    let apparentTemperatureMinTime: Int
    let apparentTemperatureMax: Double
    let apparentTemperatureMaxTime: Int
}

struct HourlyWeather: Codable {
    let summary: String
    let icon: String
    let data: [HourlyWeatherEntry]
}

struct HourlyWeatherEntry: Codable {
    let time: Int
    let summary: String
    let icon: String
    let precipIntensity: Float
    let precipProbability: Double
    let precipType: String?
    let temperature: Double
    let apparentTemperature: Double
    let dewPoint: Double
    let humidity: Double
    let pressure: Double
    let windSpeed: Double
    let windGust: Double
    let windBearing: Int
    let cloudCover: Double
    let uvIndex: Int
    let visibility: Double
    let ozone: Double
}
