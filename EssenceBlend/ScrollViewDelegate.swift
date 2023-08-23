//
//  ScrollViewDelegate.swift
//  EssenceBlend
//
//  Created by Guusje Smit on 23/08/2023.
//

import UIKit

class ScrollViewDelegate: NSObject, UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("ScrollViewWillBeginDragging")
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print("scrollViewDidZoom: \(scrollView.zoomScale)")
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print("scrollViewDidEndZooming: \(scale)")
    }
}
