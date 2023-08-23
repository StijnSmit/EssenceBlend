//
//  ViewController.swift
//  EssenceBlend
//
//  Created by Guusje Smit on 22/08/2023.
//

import UIKit

class ViewController: UIViewController {
    
    let scrollView: UIScrollView = {
        let this = UIScrollView()
        this.translatesAutoresizingMaskIntoConstraints = false
        this.maximumZoomScale = 10.0
        this.minimumZoomScale = 0.2
        return this
    }()
    var gridBackgroundView: UIView!
    
    var addedImage: UIImageView?
    var selectedImage: UIImageView?
    
    var imagePanGestureRecognizer: UIPanGestureRecognizer!
    var pinchGesture: UIPinchGestureRecognizer!
    
    let scrollViewDelegate: ScrollViewDelegate = ScrollViewDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createGestureRecognizers()
        
        let height = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 50
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: -height),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        scrollView.contentSize = CGSize(width: 10000, height: 10000)
        scrollView.delegate = scrollViewDelegate
        scrollView.setZoomScale(5.0, animated: true)
        
        // Create and add grid background view
        gridBackgroundView = createGridBackgroundView()
        scrollView.addSubview(gridBackgroundView)
        scrollView.contentSize = gridBackgroundView.frame.size
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello, World!"
        label.textAlignment = .center
        scrollView.addSubview(label)
        // Set constraints for the UILabel within the UIScrollView
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            label.widthAnchor.constraint(equalToConstant: 200), // Adjust the width as needed
            label.heightAnchor.constraint(equalToConstant: 50)  // Adjust the height as needed
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped(_:)))
        scrollView.addGestureRecognizer(tapGesture)
//        scrollView.addGestureRecognizer(pinchGesture)
    }
    
    func createGestureRecognizers() {
        imagePanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(imagePanned(_:)))
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
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
            addedImage?.isUserInteractionEnabled = true
            
            scrollView.addSubview(addedImage!)
            
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
        imageView.removeGestureRecognizer(imagePanGestureRecognizer)
        selectedImage = nil
    }
    
    @objc func imageTapped(_ gesture: UITapGestureRecognizer) {
        
        guard let imageView = gesture.view as? UIImageView else { return }
        
        if selectedImage == imageView {
            
            deselectImageView(imageView)
            
        } else {
            
            imageView.layer.borderColor = UIColor.blue.cgColor
            imageView.layer.borderWidth = 2.0
            imageView.addGestureRecognizer(imagePanGestureRecognizer)
            selectedImage = imageView
            
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
        
        guard let viewToZoom = gesture.view,
              gesture.state == .changed else { return }
//        print("The selected View to zoom is: \(viewToZoom)")

        if viewToZoom == scrollView {
            print("ScrollView zoom is currently: \(scrollView.zoomScale)")
            let newScale = scrollView.zoomScale * gesture.scale
            print("And the new scale is: \(newScale)")
            scrollView.setZoomScale(newScale, animated: true)
            scrollView.zoomScale = newScale
        } else {
            let currentScale = viewToZoom.frame.size.width / viewToZoom.bounds.size.width
            var newScale = currentScale * (gesture.scale)
            
            // Limit the zoom scale if needed
            newScale = min(max(newScale, 0.5), 2.0)
            
            let transform = viewToZoom.transform.scaledBy(x: newScale, y: newScale)
            viewToZoom.transform = transform
            gesture.scale = 1
        }
        
    }
    
    func createGridBackgroundView() -> UIView {
        
        let backgroundView = UIView(frame: CGRect(origin: .zero, size: scrollView.contentSize))
        
        // Set up grid pattern
        let gridSize: CGFloat = 20.0 // Adjust as needed
        let gridPatternSize = CGSize(width: gridSize, height: gridSize)
        UIGraphicsBeginImageContextWithOptions(gridPatternSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(CGRect(origin: .zero, size: gridPatternSize))
        
        context?.setLineWidth(1.0)
        context?.setStrokeColor(UIColor.lightGray.cgColor)
        
        context?.move(to: CGPoint(x: 0, y: gridSize))
        context?.addLine(to: CGPoint(x: gridSize, y: gridSize))
        context?.addLine(to: CGPoint(x: gridSize, y: 0))
        context?.strokePath()
        
        let patternImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        backgroundView.frame.size = scrollView.contentSize
        
        backgroundView.backgroundColor = UIColor(patternImage: patternImage!)
        return backgroundView
    }
}
