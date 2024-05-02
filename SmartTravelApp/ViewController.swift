//
//  ViewController.swift
//  SmartTravelApp
//
//  Created by student on 2/5/2024.
//

import UIKit
import AVFoundation
import Foundation

class ViewController: UIViewController ,UICollectionViewDelegate, UICollectionViewDataSource  {

    var timer = Timer()
    var counter = 0
    @IBOutlet weak var guestNameLabel: UILabel!
    static var name = "Guest"
    @IBOutlet weak var helloLebel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    var sliderArray:[UIImage] = [UIImage]()
    
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet weak var pageView: UIPageControl!
    
   
    var registerUsername:String = ""
    var registerPassword:String = ""
   
    
    override func viewDidLoad() {
        super.viewDidLoad()


        sliderArray = [UIImage(named: "01")!,UIImage(named: "02")!,UIImage(named: "03")!]
        
        // Do any additional setup after loading the view.
        sliderCollectionView.delegate = self
        sliderCollectionView.dataSource = self
        sliderCollectionView.reloadData()
        
        self.sliderCollectionView.register(UINib(nibName: "SliderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SliderCollectionViewCell")
        showSlider()
    
       
        
    }

    func showSlider(){
        
        pageView.numberOfPages = sliderArray.count
        pageView.currentPage = 0
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
        }
    }
    @objc func changeImage() {
        
        if counter < sliderArray.count {
            let index = IndexPath.init(item: counter, section: 0)
            self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
            pageView.currentPage = counter
            counter += 1
        } else {
            counter = 0
            let index = IndexPath.init(item: counter, section: 0)
            self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
            pageView.currentPage = counter
            counter = 1
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sliderArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderCollectionViewCell", for: indexPath) as? SliderCollectionViewCell
        
        if let vc = cell!.viewWithTag(111) as? UIImageView {
            
            let img = sliderArray[indexPath.row]
            cell?.sliderImage.image = img
            cell?.sliderImage.contentMode = .scaleAspectFill
            cell?.sliderImage.layer.cornerRadius = 15
        }
        return cell!
    }

}
extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = sliderCollectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
       
    }
    
    
}

