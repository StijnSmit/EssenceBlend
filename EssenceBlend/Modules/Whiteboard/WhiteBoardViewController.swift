//
//  ViewController.swift
//  EssenceBlend
//
//  Created by Guusje Smit on 22/08/2023.
//

import UIKit

class WhiteBoardViewController: UIViewController {
    
    let paperColor = UIColor(red: 1.0, green: 0.995, blue: 0.951, alpha: 1.0)
    
    var scrollView: UIScrollView!
    
    lazy var itemEditMenu: UIMenu = {
        UIMenu(title: "Title", options: .displayInline, children: [
            UIAction(title: "Photo", handler: { [weak self] _ in
                self?.showImagePickerOverlay()
            }),
            UIAction(title: "Text", handler: { _ in
                print("MenuItem1")
            }),
        ])
    }()
    
    lazy var itemSelectedMenu: UIMenu = {
        UIMenu(title: "Title", options: .displayInline, children: [
            UIAction(title: "Delete", handler: { _ in
                self.deleteSelectedImage()
            }),
            UIAction(title: "Duplicate", handler: { [weak self] _ in
                print("Duplicate")
            }),
            UIAction(title: "Preview", handler: { _ in
                print("MenuItem1")
            })
        ])
    }()
    
    var board: UIView!
    var selectedImageView: UIImageView?
    
    var topBar: BordNavigationBar!
    var floatingActionBar: FloatingActionBar!
    
    var panGesture: UIPanGestureRecognizer!
    var longPressGesture: UILongPressGestureRecognizer!
    
    var editMenuInteraction: UIEditMenuInteraction!
    
    var zoomScale: Double = 1.0
    var scrollDelegate = ScrollViewDelegate()
    
    var imageViews: [UIImageView] = []
    
    var itemEditMenuLocation: CGPoint? = nil
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewWillLayoutSubviews() {
        topBar.layout()
        floatingActionBar.layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = paperColor
        
        createScrollView()
        createBord()
        
        scrollView.addSubview(board)
        scrollView.contentSize = board.frame.size
        
        setupEditMenuInteraction()
        
        createTopBar()
        createFloatingActionBar()
        
        createGestureRecognizers()
        
        // Simple hello world label
        let label = UILabel()
        label.anchorPoint = CGPoint(x: 0, y: 0)
        label.frame = CGRect(x: 100, y: 100, width: 200, height: 50)
        
        label.text = "Hello, World!"
        label.textColor = UIColor.black
        label.textAlignment = .center
        board.addSubview(label)
    }
    
    func createGestureRecognizers() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(imagePanned(_:)))
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped(_:)))
        scrollView.addGestureRecognizer(tapGesture)
        scrollView.addGestureRecognizer(longPressGesture)
    }
    
    func createGridBackgroundView() -> UIView {
        
        let backgroundView = UIView()
        backgroundView.anchorPoint = CGPoint(x: 0, y: 0)
        backgroundView.frame = CGRect(origin: .zero, size: scrollView.contentSize)
        
        // Set up grid pattern
        let gridSize: CGFloat = 40.0 // Adjust as needed
        let gridPatternSize = CGSize(width: gridSize, height: gridSize)
        UIGraphicsBeginImageContextWithOptions(gridPatternSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(paperColor.cgColor)
        context?.fill(CGRect(origin: .zero, size: gridPatternSize))
        
        context?.setLineWidth(1.0)
        context?.setStrokeColor(UIColor.lightGray.withAlphaComponent(0.8).cgColor)
        
        context?.move(to: CGPoint(x: 0, y: gridSize))
        context?.addLine(to: CGPoint(x: gridSize, y: gridSize))
        context?.addLine(to: CGPoint(x: gridSize, y: 0))
        context?.strokePath()
        
        let patternImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        backgroundView.backgroundColor = UIColor(patternImage: patternImage!)
        
        return backgroundView
    }
}

/// UI Setup
extension WhiteBoardViewController {
    
    func createScrollView() {
        
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.maximumZoomScale = 10.0
        scrollView.minimumZoomScale = 0.2
        view.insertSubview(scrollView, at: 0)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        scrollView.contentSize = CGSize(width: 10000, height: 10000)
        scrollView.delegate = scrollDelegate
    }
    
    func createBord() {
        
        board = UIView()
        board.anchorPoint = CGPoint(x: 0, y: 0)
        board.frame = CGRect(origin: .zero, size: scrollView.contentSize)
        board.addSubview(createGridBackgroundView())
    }
    
    func createTopBar() {
        topBar = BordNavigationBar()
        topBar.delegate = self
        view.addSubview(topBar)
        NSLayoutConstraint.activate([
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            topBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            topBar.widthAnchor.constraint(equalToConstant: 130),
            topBar.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    func createFloatingActionBar() {
        floatingActionBar = FloatingActionBar()
        view.addSubview(floatingActionBar)
        NSLayoutConstraint.activate([
            floatingActionBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            floatingActionBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            floatingActionBar.widthAnchor.constraint(equalToConstant: 110),
            floatingActionBar.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
}

/// Create and Delete images
extension WhiteBoardViewController {
    
    func add(_ image: UIImage, at: CGPoint) {
        
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(
            x: at.x,
            y: at.y,
            width: image.size.width,
            height: image.size.height)
        imageView.isUserInteractionEnabled = true
        board.addSubview(imageView)
        
        let imageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imageView.addGestureRecognizer(imageTapGestureRecognizer)
        
        imageViews.append(imageView)
        selectImageView(imageView)
    }
    
    func deleteSelectedImage() {
        
        imageViews.removeAll { imageView in
            imageView == selectedImageView
        }
        selectedImageView?.removeFromSuperview()
        selectedImageView = nil
    }
}

/// Image selection and deselection
extension WhiteBoardViewController {
    
    func selectImageView(_ imageView:  UIImageView) {
        
        if let selectedImageView {
            deselectImageView(selectedImageView)
        }
        
        imageView.layer.borderColor = UIColor.tintColor.cgColor
        imageView.layer.borderWidth = 2.0
        imageView.addGestureRecognizer(panGesture)
        selectedImageView = imageView
        
        let config = createItemSelectedMenuConfiguration(item: imageView)
        let configuration = UIEditMenuConfiguration(identifier: "itemSelected", sourcePoint: config.0)
        configuration.preferredArrowDirection = config.1
        editMenuInteraction.presentEditMenu(with: configuration)
    }
    
    func deselectImageView(_ imageView: UIImageView) {
        
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.borderWidth = 0.0
        imageView.removeGestureRecognizer(panGesture)
        selectedImageView = nil
    }
}

/// Gesture handlers
extension WhiteBoardViewController {
    
    @objc func scrollViewTapped(_ gesture: UITapGestureRecognizer) {
        if let selectedImageView {
            deselectImageView(selectedImageView)
        }
    }
    
    @objc func imageTapped(_ gesture: UITapGestureRecognizer) {
        
        guard let imageView = gesture.view as? UIImageView else { return }
        
        if selectedImageView == imageView {
            deselectImageView(imageView)
        } else {
            selectImageView(imageView)
        }
    }
    
    @objc func imagePanned(_ gesture: UIPanGestureRecognizer) {
        
        guard let imageView = gesture.view as? UIImageView else { return }
        
        let translation = gesture.translation(in: scrollView)
        imageView.center.x += translation.x
        imageView.center.y += translation.y
        
        gesture.setTranslation(.zero, in: scrollView)
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        
        guard gesture.state == .began else { return }
        
        itemEditMenuLocation = gesture.location(in: scrollView)
        let configuration = UIEditMenuConfiguration(identifier: "longPressEdit", sourcePoint: gesture.location(in: scrollView))
        editMenuInteraction.presentEditMenu(with: configuration)
    }
}

/// EditMenu
extension WhiteBoardViewController: UIEditMenuInteractionDelegate {
    
    func setupEditMenuInteraction() {
        
        editMenuInteraction = UIEditMenuInteraction(delegate: self)
        scrollView.addInteraction(editMenuInteraction)
    }
    
    func editMenuInteraction(_ interaction: UIEditMenuInteraction, menuFor configuration: UIEditMenuConfiguration, suggestedActions: [UIMenuElement]) -> UIMenu? {
        
        if configuration.identifier.description == "longPressEdit" {
            return UIMenu(children: itemEditMenu.children)
        } else if configuration.identifier.description == "itemSelected" {
            return UIMenu(children: itemSelectedMenu.children)
        } else {
            return nil
        }
    }
    
    func createItemSelectedMenuConfiguration(item: UIView) -> (CGPoint, UIEditMenuArrowDirection) {
        
        let scrollViewBounds = scrollView.bounds
        let zoomScale = scrollView.zoomScale
        
        let minimumDistance = 110 / zoomScale
        
        // Calculate the visible from of the scrollView
        let visibleFrame = CGRect(x: scrollView.contentOffset.x,
                                  y: scrollView.contentOffset.y,
                                  width: scrollViewBounds.width / zoomScale,
                                  height: scrollViewBounds.height / zoomScale)
        
        let scaledItemFrame = CGRect(
            x: zoomScale * item.frame.minX,
            y: zoomScale * item.frame.minY,
            width: zoomScale * item.frame.width,
            height: zoomScale * item.frame.height)
        
        // Above
        if scaledItemFrame.minY - visibleFrame.minY > minimumDistance {
            print("Above with distance: \(scaledItemFrame.minY - visibleFrame.minY)")
            return (CGPoint(x: scaledItemFrame.midX, y: scaledItemFrame.minY), .down)
        }
        
        if visibleFrame.maxY - scaledItemFrame.maxY > minimumDistance {
            print("Below with distance: \(visibleFrame.maxY - scaledItemFrame.maxY)")
            return (CGPoint(x: scaledItemFrame.midX, y: scaledItemFrame.maxY), .up)
        }
        
        print("Middle")
        return (CGPoint(x: scaledItemFrame.midX, y: scaledItemFrame.midY), .down)
    }
}

/// Image Picker
extension WhiteBoardViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showImagePickerOverlay() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        // Create a new view controller to host the image picker
        modalPresentationStyle = .overCurrentContext
        
        // Present the image picker with the overlay view controller
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true)
        itemEditMenuLocation = nil
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        
        guard let pickedImage = info[.originalImage] as? UIImage,
              let tapLocation = itemEditMenuLocation else { return }
        
        let scaledImage = scaleImage(pickedImage)
        
        add(scaledImage, at: tapLocation)
    }
    
    func scaleImage(_ image: UIImage) -> UIImage {
        
        let maxWidth: CGFloat = 400
        let maxHeight: CGFloat = 500
        
        let widthRatio = maxWidth / image.size.width
        let heightRatio = maxHeight / image.size.height
        
        var newSize: CGSize
        if widthRatio < heightRatio {
            newSize = CGSize(width: maxWidth, height: image.size.height * widthRatio)
        } else {
            newSize = CGSize(width: image.size.width * heightRatio, height: maxHeight)
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage ?? image
    }
}

extension WhiteBoardViewController: BordNavigationBarDelegate {
    
    func back() {
        navigationController?.popViewController(animated: true)
    }
    
    func undo() { print("Undo") }
    func redo() { print("Redo") }
}
