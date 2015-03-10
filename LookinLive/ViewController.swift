//
//  ViewController.swift
//  LookinLive
//
//  Created by Eric Larson on 2/26/15.
//  Copyright (c) 2015 Eric Larson. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var videoManager : VideoAnalgesic! = nil
    let filter :CIFilter = CIFilter(name: "CIBumpDistortion")
    
    @IBAction func panRecognized(sender: AnyObject) {
        let point = sender.translationInView(self.view)
        
        var swappedPoint = CGPoint()
        
        // convert coordinates from UIKit to core image
        var transform = CGAffineTransformIdentity
        transform = CGAffineTransformConcat(transform, CGAffineTransformMakeRotation(CGFloat(M_PI_2)))
        transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(-1.0, 1.0))
        transform = CGAffineTransformTranslate(transform, self.view.bounds.size.width/2,
            self.view.bounds.size.height/2)
        
        swappedPoint = CGPointApplyAffineTransform(point, transform);
        
//        filter.setValue(CIVector(CGPoint: swappedPoint), forKey: "inputCenter")

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = nil
        
        self.videoManager = VideoAnalgesic.sharedInstance
        self.videoManager.setCameraPosition(AVCaptureDevicePosition.Back)
        
        self.filter.setValue(-0.5, forKey: "inputScale")
        filter.setValue(75, forKey: "inputRadius")
        
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyLow]
        
        let detector = CIDetector(ofType: CIDetectorTypeFace,
            context: self.videoManager.getCIContext(),
            options: optsDetector)
        
        
        
        self.videoManager.setProcessingBlock( { (imageInput) -> (CIImage) in
            var optsFace = [CIDetectorImageOrientation:self.videoManager.getImageOrientationFromUIOrientation(UIApplication.sharedApplication().statusBarOrientation)]
            
            var features = detector.featuresInImage(imageInput, options: optsFace)
            var swappedPoint = CGPoint()
            for f in features as [CIFaceFeature]{
                NSLog("%@",f)
                swappedPoint.x = f.bounds.midX
                swappedPoint.y = f.bounds.midY
                self.filter.setValue(CIVector(CGPoint: swappedPoint), forKey: "inputCenter")
            }
            
            
            self.filter.setValue(imageInput, forKey: kCIInputImageKey)
            return self.filter.outputImage
        })
        
        self.videoManager.start()
    }

    @IBAction func flash(sender: AnyObject) {
        self.videoManager.toggleFlash()
    }
    
    @IBAction func switchCamera(sender: AnyObject) {
        self.videoManager.toggleCameraPosition()
    }

    @IBAction func setFlashLevel(sender: UISlider) {
        self.videoManager.turnOnFlashwithLevel(sender.value)
    }
}

