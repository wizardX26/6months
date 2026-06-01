//
//  CategoryViewController.swift
//  ChipPage
//
//  Created by wizard.os25 on 1/6/26.
//

import UIKit

class CategoryViewController: UIViewController {

    @IBOutlet weak var chipCollectionView: UICollectionView!
    @IBOutlet weak var contentView: UIView!
    
    var chipData: [String] = []
    var pages: [UIViewController] = []
    var currentIndex: Int = 0
    
    var pageViewController: UIPageViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let followerViewController = UIStoryboard(name: "FollowerViewController", bundle: nil)
            .instantiateViewController(withIdentifier: "FollowerViewController")
        
        let followingViewController = UIStoryboard(name: "FollowingViewController", bundle: nil)
            .instantiateViewController(withIdentifier: "FollowingViewController")
        
        self.pages = [followerViewController, followingViewController]
        self.pageViewController.setViewControllers([self.pages[self.currentIndex]],
                                                   direction: .forward,
                                                   animated: true,
                                                   completion: nil)
        
        self.chipCollectionView.delegate = self
        self.chipCollectionView.dataSource = self
        
        guard let url = Bundle.main.url(forResource: "data", withExtension: "json") else {
            print("Cannot find data.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(ChipData.self, from: data)
            self.chipData = config.chips ?? ["No chips"]
        } catch {
            print("Error: \(error)")
        }
    
        
    
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "embedPageViewController" {
            let pageViewController = segue.destination as! UIPageViewController
            self.pageViewController = pageViewController
            self.pageViewController.delegate = self
            self.pageViewController.dataSource = self
        }
    }
}
