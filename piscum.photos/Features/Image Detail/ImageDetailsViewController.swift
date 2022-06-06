//
//  ImageDetailsViewController.swift
//  piscum.photos
//
//  Created by Danial Fajar on 05/06/2022.
//

import UIKit

class ImageDetailsViewController: UIViewController {

    @IBOutlet weak var imageTypeSegmentation: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var blurSlider: UISlider!
    @IBOutlet weak var blurView: UIStackView!
    
    @IBOutlet weak var blurAmountLbl: UILabel!
    @IBOutlet weak var imageIDLbl: UILabel!
    @IBOutlet weak var authorLbl: UILabel!
    @IBOutlet weak var widthLbl: UILabel!
    @IBOutlet weak var heightLbl: UILabel!
    
    var piscumData: PicsumDataModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Image Details"
        
        self.setupLbl()
        self.setupSlider()
        self.setupImageView()
        self.setupSegmentation()
    }
    
    deinit {
        print("ImageDetailsViewController deinit")
    }
    
    //MARK: - Setup View 
    func setupLbl() {
        self.imageIDLbl.text = "ID: \(self.piscumData?.id ?? "0")"
        self.imageIDLbl.changeCertainTextColor(fullText: self.imageIDLbl.text ?? "", changeText: "\(self.piscumData?.id ?? "0")", color: UIColor.systemBlue)
        self.imageIDLbl.isUserInteractionEnabled = true
        self.imageIDLbl.lineBreakMode = .byWordWrapping
        self.imageIDLbl.textAlignment = .left
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tappedOnLabel(_:)))
        tapGesture.numberOfTouchesRequired = 1
        self.imageIDLbl.addGestureRecognizer(tapGesture)
        
        self.authorLbl.text = "Author: \(self.piscumData?.author ?? "")"
        self.widthLbl.text = "Width: \(self.piscumData?.width ?? 0)"
        self.heightLbl.text = "Height: \(self.piscumData?.height ?? 0)"
    }
    
    func setupSlider() {
        self.blurSlider.value = 1
        self.blurSlider.minimumValue = 1
        self.blurSlider.maximumValue = 10
        
        self.blurAmountLbl.text = "\(Int(self.blurSlider.value))"
        
        self.blurSlider.addTarget(self, action: #selector(self.doSlider(_:)), for: .valueChanged)
    }
    
    func setupImageView() {
        self.imageView.layer.cornerRadius = 8.0
        
        self.loadImageFromUrl("")
    }
    
    func setupSegmentation() {
        self.imageTypeSegmentation.addTarget(self, action: #selector(doChangeImageType(_:)), for: .valueChanged)
    }
    
    //MARK: - Function
    func loadImageFromUrl(_ urlExtension: String) {
        guard let defaultImage = UIImage(named: "no_image_small") else { return }
        guard let imageUrl = self.piscumData?.download_url else { return }
        
        WebService.loadImageData(self.imageView, imageURL: imageUrl + urlExtension, defaultImage: defaultImage) { (status) in }
    }
    
    //MARK: - Action Function
    @objc func tappedOnLabel(_ gesture: UITapGestureRecognizer) {
        guard let text = self.imageIDLbl.text else { return }
        let idRange = (text as NSString).range(of: "\(self.piscumData?.id ?? "0")")
        if gesture.didTapAttributedTextInLabel(label: self.imageIDLbl, inRange: idRange) {
            guard let url = URL(string: self.piscumData?.url ?? "") else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func doChangeImageType(_ sender: UISegmentedControl) {
        self.blurView.isHidden = sender.selectedSegmentIndex == 1 ? false : true
        
        if sender.selectedSegmentIndex == 0 {
            self.loadImageFromUrl("")
        } else if sender.selectedSegmentIndex == 1 {
            self.loadImageFromUrl("?blur=\(Int(self.blurSlider.value))")
        } else {
            self.loadImageFromUrl("?grayscale")
        }
    }
    
    @objc func doSlider(_ sender: UISlider) {
        self.blurAmountLbl.text = "\(Int(sender.value))"
        self.loadImageFromUrl("?blur=\(Int(self.blurSlider.value))")
    }
}
