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

    // outlets in view
    @IBOutlet weak var flashSlider: UISlider!
    
    // the video manager model
    var videoManager : VideoAnalgesic! = nil
    
    // any custom filters we want
    let filter :CIFilter = CIFilter(name: "CIBumpDistortion")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // we take over the very back view, so make this no color
        self.view.backgroundColor = nil
        
        // set the video model to the shared instance of the class
        self.videoManager = VideoAnalgesic.sharedInstance
        
        // at startup, let's use the back camera
        self.videoManager.setCameraPosition(AVCaptureDevicePosition.Back)
        
        // setup some parameters of the filter
        self.filter.setValue(-0.5, forKey: "inputScale")
        self.filter.setValue(75, forKey: "inputRadius")
        
        // create dictionary for face detection
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyLow, CIDetectorTracking:true]
        // could also do things like CIDetectorMinFeatureSize:
        
        // setup a face detector in swift
        let detector = CIDetector(ofType: CIDetectorTypeFace,
            context: self.videoManager.getCIContext(),
            options: optsDetector as [NSObject : AnyObject])
        
        
        // set the processing closure
        // sorry, for using the objective c "block" terminology
        //          old habits die hard...
        // This closure is called for all incoming images from the video camera
        // Thi particular example detects a face and then sets the bump distortion on top of the face
        self.videoManager.setProcessingBlock( { (imageInput) -> (CIImage) in
            
            // this ungodly mess makes sure the image is the correct orientation
            var optsFace = [CIDetectorImageOrientation:self.videoManager.getImageOrientationFromUIOrientation(UIApplication.sharedApplication().statusBarOrientation)]
            
            // get the face features
            var features = detector.featuresInImage(imageInput, options: optsFace)
            var filterCenter = CGPoint()
            
            // grab the last face and set it as center (easy to also do this for every face)
            for f in features as! [CIFaceFeature]{
                filterCenter.x = f.bounds.midX
                filterCenter.y = f.bounds.midY
                self.filter.setValue(CIVector(CGPoint: filterCenter), forKey: "inputCenter")
            }
            
            // if we had a face, filter it and return it to be displayed
            if features.count>0 {
                self.filter.setValue(imageInput, forKey: kCIInputImageKey)
                return self.filter.outputImage
            }
            else{
                // else do not filter, just return the original image
                return imageInput
            }
            
        })
        
        self.videoManager.start()
    }

    // some convenience methods
    @IBAction func flash(sender: AnyObject) {
        if(self.videoManager.toggleFlash()){
            self.flashSlider.value = 1.0
        }
        else{
            self.flashSlider.value = 0.0
        }
    }
    
    @IBAction func switchCamera(sender: AnyObject) {
        self.videoManager.toggleCameraPosition()
    }

    @IBAction func setFlashLevel(sender: UISlider) {
        if(sender.value>0.0){
            self.videoManager.turnOnFlashwithLevel(sender.value)
        }
        else if(sender.value==0.0){
            self.videoManager.turnOffFlash()
        }
    }
}

