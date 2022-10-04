import UIKit

class TabBarControllerMain: VariousTabbarController {
    private let SO = Single.getSO();
    
    // Swipe Gesture Recognizer!!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeRight.direction = .right
        //self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeLeft.direction = .left
        //self.view.addGestureRecognizer(swipeLeft)
        
        
        
        let tabBar = self.tabBar
        
        tabBar.tintColor = UIColor(rgb: 0x00BA87)
        
        let tabBarItem1 = tabBar.items![0] as UITabBarItem
        let tabBarItem2 = tabBar.items![1] as UITabBarItem
        let tabBarItem3 = tabBar.items![2] as UITabBarItem
        let tabBarItem4 = tabBar.items![3] as UITabBarItem
        
        tabBarItem1.title = "골투샵".localized;
        tabBarItem2.title = "트레이드".localized;
        tabBarItem3.title = "커뮤니티".localized;
        tabBarItem4.title = "인벤토리".localized;
        
        //tabBarItem1.image = UIImage(named: "bar_01")?.resizeImage(targetSize: CGSize(width: 25, height: 25))
//        tabBarItem1.image = UIImage(named: "bar_01")
//        tabBarItem2.image = UIImage(named: "bar_02")
//        tabBarItem3.image = UIImage(named: "bar_03")
//        tabBarItem4.image = UIImage(named: "bar_04")
//        
//
//        tabBarItem1.selectedImage = UIImage(named: "bar_01_on")
//        tabBarItem2.selectedImage = UIImage(named: "bar_02_on")
//        tabBarItem3.selectedImage = UIImage(named: "bar_03_on")
//        tabBarItem4.selectedImage = UIImage(named: "bar_04_on")
        
        // Do any additional setup after loading the view.
    }
 
 
    @objc func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        
        if gesture.direction == .left {
            if (self.selectedIndex) < 2 { // 슬라이드할 탭바 갯수 지정 (전체 탭바 갯수 - 1)
                //animateToTab(toIndex: self.selectedIndex+1)
            }
        } else if gesture.direction == .right {
            if (self.selectedIndex) > 0 {
                //animateToTab(toIndex: self.selectedIndex-1)
            }
        }
    }
}
 
extension TabBarControllerMain: UITabBarControllerDelegate  {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let tabViewControllers = tabBarController.viewControllers, let toIndex = tabViewControllers.firstIndex(of: viewController) else {
            return false
        }
        
        if toIndex == 3 && super.getUserSeq() == "" {
            //인벤토리탭은 로그인이 아니라면 접근불가
            
            LoginMove();
            
            return false;
        }
        SO.setTabbarIndex(TabbarIndex: toIndex)
        animateToTab(toIndex: toIndex)
        return true
    }
    
    func animateToTab(toIndex: Int) {
        guard let tabViewControllers = viewControllers,
            let selectedVC = selectedViewController else { return }
        
        guard let fromView = selectedVC.view,
            let toView = tabViewControllers[toIndex].view,
            let fromIndex = tabViewControllers.firstIndex(of: selectedVC),
            fromIndex != toIndex else { return }
        
        
        // Add the toView to the tab bar view
        fromView.superview?.addSubview(toView)
        
        // Position toView off screen (to the left/right of fromView)
        let screenWidth = UIScreen.main.bounds.size.width
        let scrollRight = toIndex > fromIndex
        let offset = (scrollRight ? screenWidth : -screenWidth)
        toView.center = CGPoint(x: fromView.center.x + offset, y: toView.center.y)
        
        // Disable interaction during animation
        view.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: .curveEaseOut,
                       animations: {
                        // Slide the views by -offset
                        fromView.center = CGPoint(x: fromView.center.x - offset, y: fromView.center.y)
                        toView.center = CGPoint(x: toView.center.x - offset, y: toView.center.y)
                        
        }, completion: { finished in
            // Remove the old view from the tabbar view.
            fromView.removeFromSuperview()
            self.selectedIndex = toIndex
            self.view.isUserInteractionEnabled = true
        })
    }
}

