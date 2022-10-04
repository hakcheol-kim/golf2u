import Foundation
import UIKit

class ListViewHelper {

    class func TableViewEmptyMessage(message:String, viewController:UIViewController, tableviewController:UITableView) {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: viewController.view.bounds.size.width, height: viewController.view.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        tableviewController.backgroundView = messageLabel;
        //viewController.tableView.separatorStyle = .None;
    }
    class func TableViewEmptyMessage(message:String, viewController:UIView, tableviewController:UITableView) {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: viewController.bounds.size.width, height: viewController.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        tableviewController.backgroundView = messageLabel;
        //viewController.tableView.separatorStyle = .None;
    }
    class func CollectionViewEmptyMessage(message:String, viewController:UIViewController, tableviewController:UICollectionView) {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: viewController.view.bounds.size.width, height: viewController.view.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        tableviewController.backgroundView = messageLabel;
        //viewController.tableView.separatorStyle = .None;
    }
    class func CollectionViewEmptyMessage(message:String, viewController:UIView, tableviewController:UICollectionView) {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: viewController.bounds.size.width, height: viewController.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        tableviewController.backgroundView = messageLabel;
        //viewController.tableView.separatorStyle = .None;
    }
    class func FriendUVCollectionViewEmptyMessage( viewController:UIView, tableviewController:UICollectionView){
        
        let fm_tUVView = UVView(frame: viewController.bounds)
        tableviewController.backgroundView = fm_tUVView;
        //viewController.tableView.separatorStyle = .None;
    }
    
    class func PdCommentUVCollectionViewEmptyMessage( viewController:VariousViewController, tableviewController:UICollectionView){
        
        let fm_tUVView = MainProductNodata(frame: viewController.view.bounds)
        tableviewController.backgroundView = fm_tUVView;
        //viewController.tableView.separatorStyle = .None;
    }
}
