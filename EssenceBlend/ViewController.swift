//
//  ViewController.swift
//  EssenceBlend
//
//  Created by Guusje Smit on 22/08/2023.
//

import UIKit

class ViewController: UIViewController {
    
    let paperColor = UIColor(red: 1.0, green: 0.995, blue: 0.951, alpha: 1.0)
    
    let scrollView: UIScrollView = {
        let this = UIScrollView()
        this.translatesAutoresizingMaskIntoConstraints = false
        this.maximumZoomScale = 10.0
        this.minimumZoomScale = 0.2
        return this
    }()
    var board: UIView!
    
    var addedImage: UIImageView?
    var selectedImage: UIImageView?
    
    var topBar: BoardNavigationBar!
    var floatingActionBar: FloatingActionBar!
    
    var panGesture: UIPanGestureRecognizer!
    var pinchGesture: UIPinchGestureRecognizer!
    var longPressGesture: UILongPressGestureRecognizer!
    
    var editMenuInteraction: UIEditMenuInteraction!
    
    var zoomScale: Double = 1.0
    
    var scrollDelegate = ScrollViewDelegate()
    
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
        createGestureRecognizers()
        setupEditMenuInteraction()
        
        view.backgroundColor = paperColor

        view.insertSubview(scrollView, at: 0)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        scrollView.contentSize = CGSize(width: 10000, height: 10000)
        scrollView.delegate = scrollDelegate
        
        // Create and add grid background view
        board = createBoard()
        scrollView.addSubview(board)
        scrollView.contentSize = board.frame.size
        
        topBar = BoardNavigationBar()
        topBar.delegate = self
        view.addSubview(topBar)
        NSLayoutConstraint.activate([
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            topBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            topBar.widthAnchor.constraint(equalToConstant: 130),
            topBar.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        floatingActionBar = FloatingActionBar()
        view.addSubview(floatingActionBar)
        NSLayoutConstraint.activate([
            floatingActionBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            floatingActionBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            floatingActionBar.widthAnchor.constraint(equalToConstant: 110),
            floatingActionBar.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        let label = UILabel()
        label.anchorPoint = CGPoint(x: 0, y: 0)
        label.frame = CGRect(x: 100, y: 100, width: 200, height: 50)
        
        label.text = "Hello, World!"
        label.textAlignment = .center
        board.addSubview(label)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped(_:)))
        scrollView.addGestureRecognizer(tapGesture)
        scrollView.addGestureRecognizer(longPressGesture)
    }
    
    func createGestureRecognizers() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(imagePanned(_:)))
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
    }
    
    @objc func scrollViewTapped(_ gesture: UITapGestureRecognizer) {
        // Handle tap gesture on the UIScrollView
        // This method will be called when the user taps on the scroll view
        let tapLocation = gesture.location(in: scrollView)
        
        if addedImage == nil, let image = UIImage(named: "pencil") {
            addedImage = UIImageView(image: image)
            addedImage!.frame = CGRect(
                x: tapLocation.x,
                y: tapLocation.y,
                width: image.size.width,
                height: image.size.height)
            //            addedImage?.anchorPoint = CGPoint(x: 0, y: 0)
            addedImage?.isUserInteractionEnabled = true
            
            board.addSubview(addedImage!)
            
            let imageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            addedImage?.addGestureRecognizer(imageTapGestureRecognizer)
        }
        
        if let selectedImage {
            deselectImageView(selectedImage)
        }
    }
    
    func deselectImageView(_ imageView: UIImageView) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.borderWidth = 0.0
        imageView.removeGestureRecognizer(panGesture)
        selectedImage = nil
    }
    
    func createBoard() -> UIView {

        let board = UIView()
        board.anchorPoint = CGPoint(x: 0, y: 0)
        board.frame = CGRect(origin: .zero, size: scrollView.contentSize)
        
        board.addSubview(createGridBackgroundView())
        
        return board
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
        
//        backgroundView.frame.size = scrollView.contentSize
        backgroundView.backgroundColor = UIColor(patternImage: patternImage!)
        
        return backgroundView
    }
}

/// Gesture handlers
extension ViewController {
    
    @objc func imageTapped(_ gesture: UITapGestureRecognizer) {
        
        guard let imageView = gesture.view as? UIImageView else { return }
        
        if selectedImage == imageView {
            
            deselectImageView(imageView)
            
        } else {
            
            imageView.layer.borderColor = UIColor.blue.cgColor
            imageView.layer.borderWidth = 2.0
            imageView.addGestureRecognizer(panGesture)
            selectedImage = imageView
            
            print("touch location: \(gesture.location(in: scrollView))")
            
            let config = createItemSelectedMenuConfiguration(item: imageView)
            let configuration = UIEditMenuConfiguration(identifier: "itemSelected", sourcePoint: config.0)
            configuration.preferredArrowDirection = config.1
            editMenuInteraction.presentEditMenu(with: configuration)
        }
    }
    
    @objc func imagePanned(_ gesture: UIPanGestureRecognizer) {
        
        guard let imageView = gesture.view as? UIImageView else { return }
        
        let translation = gesture.translation(in: scrollView)
        imageView.center.x += translation.x
        imageView.center.y += translation.y
        
        gesture.setTranslation(.zero, in: scrollView)
    }
    
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        var newScale = zoomScale * (gesture.scale)
        
        // Limit the zoom scale if needed
        newScale = min(max(newScale, 0.5), 2.0)
        zoomScale = newScale
        gesture.scale = 1
        print(zoomScale)
        
        for subView in scrollView.subviews {
            subView.transform = CGAffineTransform(scaleX: zoomScale, y: zoomScale)
        }
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let configuration = UIEditMenuConfiguration(identifier: "longPressEdit", sourcePoint: gesture.location(in: scrollView))
        editMenuInteraction.presentEditMenu(with: configuration)
    }
}

/// EditMenu
extension ViewController: UIEditMenuInteractionDelegate {
    
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
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showImagePickerOverlay() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        // Create a new view controller to host the image picker
        modalPresentationStyle = .overCurrentContext
        
        // Present the image picker with the overlay view controller
        present(imagePicker, animated: true, completion: nil)
    }
}

extension ViewController {
    func deleteSelectedImage() {
        selectedImage?.removeFromSuperview()
        selectedImage = nil
        addedImage = nil
    }
}

extension ViewController: BoardNavigationBarDelegate {
    func back() {
        navigationController?.popViewController(animated: true)
    }
    
    func undo() { print("Undo") }
    
    func redo() { print("Redo") }
}
