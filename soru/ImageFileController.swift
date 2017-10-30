//
//  ImageFileController.swift
//  soru
//
//  Created by Aditya Gurjar on 7/5/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit
class ImageFileController : UIViewController, UIScrollViewDelegate{
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = currentImage
        self.showAnimate()
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ImageFileController.removeAnimate))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
        var contentRect = CGRect.zero
        for view in self.scrollView.subviews
        {
            contentRect = contentRect.union(view.frame)
        }
        self.scrollView.contentSize = contentRect.size
        
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        
        self.removeAnimate()
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    @objc func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished : Bool) in
            if(finished)
            {
                self.willMove(toParentViewController: nil)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }
        })
    }
}
