//
//  ScrollViewDelegate.swift
//  EssenceBlend
//
//  Created by Guusje Smit on 23/08/2023.
//

import UIKit

class ScrollViewDelegate: NSObject, UIScrollViewDelegate {
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard let grid = scrollView.subviews.first?.subviews.first else { return }
        grid.isHidden = scrollView.zoomScale < 0.2
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }
}
