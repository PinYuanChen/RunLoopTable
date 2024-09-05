//
//  ViewController.swift
//  RunLoopTable
//
//  Created by Champion Chen on 2024/9/5.
//

import UIKit

class ViewController: UIViewController {
    typealias RunloopClosure = () -> Void
    var cellSettings = [IndexPath: RunloopClosure]()
    let rowHeight: CGFloat = 120
    var cachedImage = [IndexPath: UIImage]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addRunloopObserver()
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        rowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1000
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let image = cachedImage[indexPath] else {
            append(indexPath: indexPath, tableViewCell: cell)
            return
        }
        setFromCached(image: image, titleIndex: indexPath, tableCell: cell)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellSettings.removeValue(forKey: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? LogoTableViewCell else {
            return .init()
        }
        return cell
    }
}

private extension ViewController {
    func addRunloopObserver() {
        let runloop = CFRunLoopGetCurrent()
        let activities = CFRunLoopActivity.beforeWaiting.rawValue
        let observer = CFRunLoopObserverCreateWithHandler(nil, activities, true, 0) { [weak self] _,_ in
            guard let self = self,
                  !cellSettings.isEmpty,
            let visibleIndexes  = tableView.indexPathsForVisibleRows else { return }
            for index in visibleIndexes {
                guard let setting = cellSettings[index] else {
                    continue
                }
                setting()
            }
            cellSettings.removeAll()
        }
        CFRunLoopAddObserver(runloop, observer, .defaultMode)
    }
    
    func append(indexPath: IndexPath, tableViewCell: UITableViewCell) {
        guard let cell = tableViewCell as? LogoTableViewCell else {
            return
        }
        
        cellSettings[indexPath] = { [weak self] in
            guard let self = self else { return }
            
            let image: UIImage
            if let cachedImage = self.cachedImage[indexPath] {
                image = cachedImage
            } else {
                let path = Bundle.main.path(forResource: "logo", ofType: "png")
                let ogImage = UIImage(contentsOfFile: path ?? "") ?? UIImage()
                image = ogImage.resizeImage(newSize: .init(width: 60, height: 60))
                self.cachedImage[indexPath] = image
            }
            cell.logoImage.image = image
            cell.titleLabel.text = "\(indexPath)"
        }
    }
    
    func setFromCached(image: UIImage, titleIndex: IndexPath, tableCell: UITableViewCell) {
        guard let cell = tableCell as? LogoTableViewCell else { return }
        cell.logoImage.image = image
        cell.titleLabel.text = "\(titleIndex)"
    }
}

extension UIImage {
    func resizeImage(newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? self
    }
}
