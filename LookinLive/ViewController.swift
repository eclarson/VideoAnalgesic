//
//  ViewController.swift
//  LookinLive
//
//  Created by Eric Larson on 2/26/15.
//  Copyright (c) 2015 Eric Larson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var videoManager : VideoAnalgesic! = nil
    let filter :CIFilter = CIFilter(name: "CIBloom")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = nil
        
        self.videoManager = VideoAnalgesic.sharedInstance
        
        self.filter.setValue(2.0, forKey: "inputIntensity")
        self.videoManager.setProcessingBlock( { (imageInput) -> (CIImage) in
            self.filter.setValue(imageInput, forKey: kCIInputImageKey)
            return self.filter.outputImage
        })
        
        self.videoManager.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

