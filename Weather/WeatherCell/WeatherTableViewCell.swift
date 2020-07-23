//
//  WeatherTableViewCell.swift
//  Weather
//
//  Created by Peter Bassem on 7/23/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {

    static let identifier = "WeatherTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "WeatherTableViewCell", bundle: nil)
    }
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = UIColor(red: 52/255, green: 109/255, blue: 179/255, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with model: DailyWeatherEntry) {
        highTempLabel.textAlignment = .center
        lowTempLabel.textAlignment = .center
        
        lowTempLabel.text = String(Int(model.temperatureLow)) + "°"
        highTempLabel.text = String(Int(model.temperatureHigh)) + "°"
        dayLabel.text = getDayForDate(Date(timeIntervalSince1970: Double(model.time)))
        iconImageView.contentMode = .scaleAspectFit
        let icon = model.icon.lowercased()
        if icon.contains("clear") {
            iconImageView.image = UIImage(named: "clear")
        } else if icon.contains("rain") {
            iconImageView.image = UIImage(named: "rain")
        } else {
            iconImageView.image = UIImage(named: "cloud")
        }
        
    }
    
    private func getDayForDate(_ date: Date?) -> String {
        guard let inputDate = date else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: inputDate)
    }
}
