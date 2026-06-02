//
//  OnboardViewController.swift
//  ChipPage
//
//  Created by wizard.os25 on 3/6/26.
//

import UIKit

class OnboardViewController: UIViewController {

    @IBOutlet weak var containerVIew: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var pageViewController: UIPageViewController!
    private var childViewController: [UIViewController] = []
    private var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let introStoryboard = UIStoryboard(name: "IntroViewController", bundle: nil)
        let introViewController = introStoryboard.instantiateViewController(withIdentifier: "IntroViewController")
        let campingStoryboard = UIStoryboard(name: "CampingViewController", bundle: nil)
        let campingViewController = campingStoryboard.instantiateViewController(withIdentifier: "CampingViewController")
        
        self.childViewController = [introViewController, campingViewController]
        self.pageViewController.setViewControllers([self.childViewController[self.currentIndex]],
                                                   direction: .forward,
                                                   animated: true)
        self.pageControl.numberOfPages = self.childViewController.count
        self.pageControl.isUserInteractionEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedOnboardPageViewController" {
            let pageViewController = segue.destination as! UIPageViewController
            self.pageViewController = pageViewController
            self.pageViewController.delegate = self
            self.pageViewController.dataSource = self
        }
    }
    
    @IBAction func didTapTopPopButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func didTapBottomPopButton(_ sender: Any) {
        dismiss(animated: false)
    }
}

extension OnboardViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = self.childViewController.firstIndex(of: viewController),
              index > 0
        else { return nil}
        
        return self.childViewController[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = self.childViewController.firstIndex(of: viewController),
              index < self.childViewController.count - 1
        else { return nil}
        
        return self.childViewController[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let currentViewController = pageViewController.viewControllers?.first,
              let index = self.childViewController.firstIndex(of: currentViewController)
        else { return }
        
        self.currentIndex = index
        
            self.pageControl.currentPage = self.currentIndex
        self.containerVIew.backgroundColor = self.currentIndex == 0 ? .white : .systemBrown
        
    }
}
