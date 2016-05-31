import UIKit
import PureLayout

class ViewController: UIViewController {
    
    private var snapshot: UIView?
    private var sourceIndexPath: NSIndexPath?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(forAutoLayout: ())
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .SingleLine
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Default")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Indicator")
        tableView.tableFooterView = UIView()
        
        return tableView
    }()
    
    private var data: [Int] = [Int]()
    
    private var isIndicatorRowAddedInSection: Bool = false
    private var lastIndicatorRowIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.tableView)
        
        self.tableView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Top)
        self.tableView.autoPinEdgeToSuperviewEdge(.Top, withInset: 40)
        
        for index in 0..<5 {
            data.append(index)
        }
        
        let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longpressed(_:)))
        self.tableView.addGestureRecognizer(longPress)
        
    }
    
    func longpressed(sender: UILongPressGestureRecognizer) {
        let state: UIGestureRecognizerState = sender.state
        let location: CGPoint = sender.locationInView(self.tableView)
        let indexPath: NSIndexPath? = self.tableView.indexPathForRowAtPoint(location)
        
        switch (state) {
        case .Began:
            print("Began dragging")
            if let indexPath = indexPath {
                self.sourceIndexPath = indexPath
                
                let cell: UITableViewCell = self.tableView.cellForRowAtIndexPath(indexPath)!
                
                self.snapshot = self.customSnapshotFromView(cell)
                
                var center: CGPoint = cell.center
                self.snapshot!.center = center
                self.snapshot!.alpha = 0.0
                self.tableView.addSubview(self.snapshot!)
                
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    center.y = location.y
                    self.snapshot!.center = center
                    self.snapshot!.transform = CGAffineTransformMakeScale(1.05, 1.05)
                    self.snapshot!.alpha = 0.98
                    cell.alpha = 0.0
                    cell.hidden = true
                    
                })
            }
        case .Changed:
            print("Changed dragging")
            var center: CGPoint = self.snapshot!.center
            center.y = location.y
            self.snapshot!.center = center
            
            if let indexPath = indexPath, let sourceIndexPath = self.sourceIndexPath where (indexPath != sourceIndexPath) {
                //[self.objects exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                print("Moving to postion \(indexPath.row) section: \(indexPath.section)")
                
                self.tableView.moveRowAtIndexPath(sourceIndexPath, toIndexPath: indexPath)
                self.sourceIndexPath = indexPath
            }
            
        default:
            print("Cleanup dragging")
            if let sourceIndexPath = self.sourceIndexPath, let cell: UITableViewCell = self.tableView.cellForRowAtIndexPath(sourceIndexPath), let snapshot = self.snapshot {
                
                cell.alpha = 0.0
                
                UIView.animateWithDuration(0.25, animations: {
                    () -> Void in
                    
                    snapshot.center = cell.center
                    snapshot.transform = CGAffineTransformIdentity
                    snapshot.alpha = 0.0
                    cell.alpha = 1.0
                    
                    },  completion: { result in
                        
                        cell.hidden = false
                        self.sourceIndexPath = nil
                        snapshot.removeFromSuperview()
                        self.snapshot = nil
                })
            }
        }
    }
    
    
    
    func customSnapshotFromView(inputView: UIView) -> UIView {
        
        // Make an image from the input view.
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Create an image view.
        let snapshot: UIView = UIImageView(image: image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0.0
        snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
        snapshot.layer.shadowRadius = 5.0
        snapshot.layer.shadowOpacity = 0.4
        
        return snapshot
    }
}

extension ViewController: UITableViewDelegate {
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isIndicatorRowAddedInSection {
            return self.data.count + 1
        }
        return self.data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let indicatorIndexPath = self.lastIndicatorRowIndexPath where isIndicatorRowAddedInSection {
            if indicatorIndexPath.section == indexPath.section && indicatorIndexPath.row == indexPath.row {
                let cell = tableView.dequeueReusableCellWithIdentifier("Indicator", forIndexPath: indexPath)
                cell.textLabel?.text = "IndicatorView: ROW \(indexPath.row) SECTION = \(indexPath.section)"
                print("Indictorview cell for row")
                return cell
            }
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Default", forIndexPath: indexPath)
        
        cell.textLabel?.text = "ROW = \(indexPath.row) SECTION = \(indexPath.section)"
        return cell
        
    }
}