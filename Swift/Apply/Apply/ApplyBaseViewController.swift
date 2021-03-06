//
//  ApplyBaseViewController.swift
//  Apply
//
//  Created by QianTuFD on 2017/3/28.
//  Copyright © 2017年 fandy. All rights reserved.
//

import UIKit

class ApplyBaseViewController: UIViewController {
    
//    var pasteBoard = UIPasteboard.general
    typealias PickedImageHandle = (UIImage) -> ()
    var imagePickerFinishHandle: PickedImageHandle?
    
    var headViewStyle: ApplyHeadViewStyle = .none(topImage: "") {
        didSet {
            let headView = ApplyHeadViewFactory.applyHeadView(tableView: tableView, style: headViewStyle)
            headView?.delegate = self
            tableView.tableHeaderView = headView
            
        }
    }
    
    var cellItems: [ApplyTableViewCellType] = [ApplyTableViewCellType]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    // 内容数组
    // Any common String  image [UIImage]
    var cellContentDict: [IndexPath: Any?] = [IndexPath: Any?]()


    
    
    var tableView: ApplyBaseTableView = {
        let tableView = ApplyBaseTableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.bounces = false
//        tableView.backgroundColor = COLOR_efefef
        tableView.backgroundColor = UIColor.white
        ApplyTableViewCellFactory.registerApplyTableViewCell(tableView)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.white
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBarAlpha()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.subviews.first?.alpha = 1
    }

    func setupUI() {
        view.addSubview(tableView)
        automaticallyAdjustsScrollViewInsets = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: ["tableView": tableView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tableView]-0-|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: ["tableView": tableView]))
    }
    
}

extension ApplyBaseViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch cellItems[indexPath.row] {
        case .common:
            return 50
        case let .image(.images(images: images)):
            return calculateCellHeight(title: nil, images: images)
        case let .image(.titleImages(title: title, images: images)):
            return calculateCellHeight(title: title, images: images)
        case let .button(.button(title: _, top: top, bottom: bottom)):
            return top + bottom + 45.0
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        guard section == 0 else {
            return 0.1
//        }
//        switch headViewStyle {
//        case .custom:
//            return 5
//        default:
//            return 0.1
//        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
//    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
//        if action == #selector(UIResponderStandardEditActions.copy(_:)) {
//            return true
//        }
//        return false
//    }
//    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
//        let cell = tableView.cellForRow(at: indexPath) as? CommonTableViewCell
//        pasteBoard.string = cell?.descriptionLabel.text
//    }
    
}


extension ApplyBaseViewController {
    fileprivate func calculateCellHeight(title: String?, images: [UIImage?]) -> CGFloat {
        var height: CGFloat = 0.0
        let width = UIScreen.main.bounds.width - 50.f
        for image in images {
            guard let image = image else {
                return 0
            }
            let size = image.size
            let h = size.height / size.width * width
            height += h
        }
        let oneImageHeightWithMargin = images.count.f * 22.f + height // 以 22 + image 为单位图片高
        
        guard let tit = title else {
            return oneImageHeightWithMargin + 3 // 没title为 (50 / 2 = 25) - 22 = 3 多出的
        }
        
        let t = tit as NSString
        let contentSize = CGSize(width: width, height: CGFloat(MAXFLOAT))
        let h = t.textSizeWith(contentSize: contentSize, font: FONT_28PX).height
        let result = (h + 11 + 13) - 22 + oneImageHeightWithMargin + 5 
        return result
    }
//    func change(_ indexPath: IndexPath, step: Int, toImage: UIImage) {
////        imageCell.images[step] = toImage
//        var aImages: [UIImage]
//        var aTitle: String?
//
//        switch cellItems[indexPath.row] {
//        case let .image(.images(images: images)):
//            aImages = images
//        case let .image(.titleImages(title: title, images: images)):
//            aTitle = title
//            aImages = images
//        default:
//            return
//        }
//        aImages[step] = toImage
//        if let title = aTitle {
//            cellItems[indexPath.row] = ApplyTableViewCellType.image(.titleImages(title: title, images: aImages))
//        }else {
//            cellItems[indexPath.row] = ApplyTableViewCellType.image(.images(images: aImages))
//        }
//    }
}


// MARK: - UITableViewDataSource
extension ApplyBaseViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ApplyTableViewCellFactory.dequeueReusableCell(withTableView: tableView, type: cellItems[indexPath.row])!
        cell.currentIndexPath = indexPath
        cell.delegate = self
        guard let content =  cellContentDict[indexPath] else {
            return cell
        }
        cell.myCellContent = content
        return cell
    }
}


// MARK: - ApplyHeadViewDelegate
extension ApplyBaseViewController: ApplyHeadViewDelegate {
    func didSelect(_ segmentedHeadView: SegmentedHeadView, index: Int) {
        print(index)
    }
}


// MARK: - ApplyTableViewCellDelegate
extension ApplyBaseViewController: ApplyTableViewCellDelegate {
    
    func commonCell(_ commonCell: CommonTableViewCell, textFieldShouldBeginEditing textField: UITextField) {
//                guard let indexPath = commonCell.currentIndexPath else {
//                    return
//                }
//                print("第  \(indexPath) 的 arrowCellClick \(textField)")
    }

    func commonCell(_ commonCell: CommonTableViewCell, textFieldDidEndEditing textField: UITextField) {
        guard let indexPath = commonCell.currentIndexPath else {
            return
        }
        cellContentDict[indexPath] = textField.text
        print("textFieldDidEndEditing\(textField)")
    }
    
    
    func commonCell(_ commonCell: CommonTableViewCell, arrowCellClick textField: UITextField) {
//        guard let indexPath = commonCell.currentIndexPath else {
//            return
//        }
//        print("第  \(indexPath) 的 arrowCellClick \(textField)")
    }
    
    func commonCell(_ commonCell: CommonTableViewCell, verificationButtonClick verificationButton: UIButton) {
//        guard let indexPath = commonCell.currentIndexPath else {
//            return
//        }
//        print("第 \(indexPath) 的 verificationButtonClick\(verificationButton)")
    }
    
    func imageCell(_ imageCell: ImageTableViewCell, imageButtonClick imageButton: UIImageView) {
//        guard let indexPath = imageCell.currentIndexPath else {
//            return
//        }
//        print("第 \(indexPath) 的 \(imageButton.tag) verificationButtonClick\(imageButton)")
//        imageCell.images[imageButton.tag] = UIImage(named: "yyzz_btn")
//        cellContentDict[indexPath] = imageCell.images
    }
    
    func buttonCell(_ buttonCell: ButtonTableViewCell, nextButtonClick nextButton: UIButton) {
//        print("下一步点击")
//        print(cellContentDict)
    }
    
    
}

// MARK: - UIScrollViewDelegate
extension ApplyBaseViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isEqual(tableView) else {
            return
        }
        self.setupNavBarAlpha()
    }
    fileprivate func setupNavBarAlpha() {
        let offsetY = tableView.contentOffset.y
        let minOffsetY: CGFloat = 0.0
        let maxOffsetY: CGFloat = 100.0
        if offsetY > maxOffsetY {
            return
        }
        let alpha = (offsetY - minOffsetY) / (maxOffsetY - minOffsetY)
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.navigationBar.subviews.first?.alpha = alpha > 1 ? 1 : alpha
        }
    }
}

// MARK: - showAlertView
extension ApplyBaseViewController {
    func showAlertView(with message: String) {
        let alertController = UIAlertController(title: "提示:", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "确定", style: .cancel) {(_)  in
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showPhotoPickerView(finishHandel: @escaping PickedImageHandle) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action0 = UIAlertAction(title: "拍照", style: .default) {[weak self] (_)  in
            self?.showImagePickerController(sourceType: .camera, finishHandel: finishHandel)
        }
        let action1 = UIAlertAction(title: "相册", style: .default) {[weak self] (_)  in
            self?.showImagePickerController(sourceType: .photoLibrary, finishHandel: finishHandel)
        }
        let action2 = UIAlertAction(title: "取消", style: .cancel) {(_)  in
        }
        alertController.addAction(action0)
        alertController.addAction(action1)
        alertController.addAction(action2)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func showImagePickerController(sourceType: UIImagePickerControllerSourceType, finishHandel: @escaping PickedImageHandle) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = false
        self.imagePickerFinishHandle = finishHandel
        present(imagePicker, animated: true, completion: nil)
    }
}

extension ApplyBaseViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        self.imagePickerFinishHandle?(image)
        picker.dismiss(animated: true, completion: nil)
    }
}



