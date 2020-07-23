//
//  HourlyTableViewCell.swift
//  Weather
//
//  Created by Peter Bassem on 7/23/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit

class HourlyTableViewCell: UITableViewCell {
    
    static let identifier = "HourlyTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "HourlyTableViewCell", bundle: nil)
    }
    
    @IBOutlet weak var hourlyTempratureCollectionView: UICollectionView!
    
    var models = [HourlyWeatherEntry]()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = UIColor(red: 52/255, green: 109/255, blue: 179/255, alpha: 1)
        hourlyTempratureCollectionView.register(WeatherCollectionViewCell.nib(), forCellWithReuseIdentifier: WeatherCollectionViewCell.identifier)
        hourlyTempratureCollectionView.delegate = self
        hourlyTempratureCollectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with models: [HourlyWeatherEntry]) {
        self.models = models
        hourlyTempratureCollectionView.reloadData()
    }
    
}

extension HourlyTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = hourlyTempratureCollectionView.dequeueReusableCell(withReuseIdentifier: WeatherCollectionViewCell.identifier, for: indexPath) as! WeatherCollectionViewCell
        cell.configure(with: models[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}
