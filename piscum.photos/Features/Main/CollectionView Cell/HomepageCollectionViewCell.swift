//
//  HomepageCollectionViewCell.swift
//  piscum.photos
//
//  Created by Danial Fajar on 05/06/2022.
//

import UIKit

class HomepageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }

    //MARK: - Setup Table View Cell
    func configureCell(imageURL: String?) {
        guard let defaultImage = UIImage(named: "no_image_small") else { return }
        WebService.loadImageData(self.imageView, imageURL: imageURL ?? "", defaultImage: defaultImage) { (status) in }
    }
}
