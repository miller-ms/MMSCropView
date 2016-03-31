//
//  ViewController.swift
//  MMSCropView
//
//  Created by William Miller on 03/10/2016.
//  Copyright (c) 2016 William Miller. All rights reserved.
//

import UIKit
import MMSCropView

class ViewController: UIViewController {

    /// Reference to the screen's MMSCropView
    @IBOutlet weak var originalImageView: MMSCropView!
    
    ///  Reference to the screens UIImageView
    @IBOutlet weak var croppedImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**
     Linked to the crop button on the UI Screen.  When tapped, this routine crops the Image underneath the crop recthangle and displays it in the UIImageView showing the cropped image.
     
     - parameter sender: <#sender description#>
     */
    @IBAction func crop(sender: UIButton) {
        
        
        let croppedImage = originalImageView.crop()
        
        croppedImageView.image = croppedImage
        
    }

    
}

