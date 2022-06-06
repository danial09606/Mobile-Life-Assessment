//
//  HomepageCollectionViewController.swift
//  piscum.photos
//
//  Created by Danial Fajar on 05/06/2022.
//

import UIKit
import collection_view_layouts

class HomepageCollectionViewController: UICollectionViewController {
    
    private let footerView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    var piscumData: [PicsumDataModel]? = []
    var indexPage = 1
    var layout: BaseLayout = FacebookLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupCell()
        self.setupCollectionViewLayout()
        
        self.title = "Home"
        
        self.loadPiscumData { [weak self] (data) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.piscumData = data
                self.collectionView.reloadData()
            }
        }
    }
    
    //MARK: - Setup View
    func setupCell() {
        self.collectionView.register(UINib(nibName: "HomepageCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: "HomepageCollectionViewCell")
        self.collectionView.register(CollectionViewFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        (self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: self.collectionView.bounds.width, height: 50)
    }
    
    func setupCollectionViewLayout() {
        self.layout.delegate = self
        self.layout.contentPadding = ItemsPadding(horizontal: 8, vertical: 8)
        self.layout.cellsPadding = ItemsPadding(horizontal: 8, vertical: 8)
        
        self.collectionView.collectionViewLayout = self.layout
    }

    func loadPiscumData(completion: @escaping ((_ data: [PicsumDataModel]) -> ())) {
        let jsonUrlString = mainURL.webService() + "v2/list?page=\(self.indexPage)&limit=12"
        
        WebService().getData(jsonUrlString){ data in
            do {
                let dataJSON = try JSONDecoder().decode([PicsumDataModel].self, from: data)
                self.indexPage += 1
                completion(dataJSON)
            }catch let error {
                print(error)
            }
        }
    }
    
    //MARK: - Function
    func fetchAPIRequest(completion: @escaping (() ->(Void))) {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter() // Enter thread
        self.loadPiscumData { [weak self] (data) in
            guard let self = self else { return }
            self.piscumData?.append(contentsOf: data)
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }

    // MARK: - UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.piscumData?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomepageCollectionViewCell", for: indexPath) as? HomepageCollectionViewCell else { return UICollectionViewCell() }
    
        cell.configureCell(imageURL: self.piscumData?[indexPath.row].download_url)
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
            footer.addSubview(self.footerView)
            self.footerView.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: 50)
            return footer
        }
        
        return UICollectionReusableView()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ImageDetailsViewController(nibName: "ImageDetailsViewController", bundle: nil)
        vc.piscumData = self.piscumData?[indexPath.row]
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if self.piscumData?.count ?? 0 > 0 && (self.piscumData?.count ?? 0 == (indexPath.row + 1)) {
            self.footerView.startAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: { // too avoid too many request been made in one time
                self.fetchAPIRequest() {
                    UIView.performWithoutAnimation {
                        DispatchQueue.main.async { self.collectionView.reloadSections(IndexSet(integer: 0)) }
                    }
                    self.footerView.stopAnimating()
                }
            })
        }
    }
}

//MARK: - LayoutDelegate
extension HomepageCollectionViewController: LayoutDelegate {
    func cellSize(indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.piscumData?[indexPath.row].width ?? 0, height: self.piscumData?[indexPath.row].height ?? 0)
    }
}
 
