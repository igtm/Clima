//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "894417bd55cdd22c9093cd7e889a8648"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success !")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
            } else {
                print("Error !\(response.result.error)")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    /*
     {
     "main" : {
     "humidity" : 88,
     "temp_max" : 301.15,
     "temp_min" : 287.15,
     "temp" : 291.16,
     "pressure" : 1011
     },
     "name" : "San Francisco",
     "id" : 5391959,
     "coord" : {
     "lon" : -122.41,
     "lat" : 37.79
     },
     "weather" : [
     {
     "id" : 500,
     "main" : "Rain",
     "icon" : "10n",
     "description" : "light rain"
     }
     ],
     "clouds" : {
     "all" : 40
     },
     "dt" : 1498885200,
     "base" : "stations",
     "sys" : {
     "id" : 4250,
     "message" : 0.0126,
     "country" : "US",
     "type" : 1,
     "sunset" : 1498966528,
     "sunrise" : 1498913500
     },
     "cod" : 200,
     "visibility" : 10000,
     "wind" : {
     "speed" : 2.6,
     "deg" : 20
     }
     }
     */
    func updateWeatherData(json: JSON) {
        
        if let tempResult = json["main"]["temp"].double {

            weatherDataModel.temperature = Int(tempResult - 273.15)
            
            weatherDataModel.city = json["name"].stringValue
            
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherDate()
            
        } else {
            cityLabel.text = "unavailable"
        }
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherDate() {
        
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
    }
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    // [CLLocation] 一番最後の値が一番精度が高い
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        // 精度（半径？）
        print(location.horizontalAccuracy)
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude) ")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String: String] = ["lat": latitude, "lon": longitude, "appid": APP_ID ]

            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "位置情報が取得できません"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city : String) {
        print(city)
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
        }
    }
    
    
    
    
}


