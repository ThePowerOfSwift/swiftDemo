//
//  cameraFrameProcessor.swift
//  Demo
//
//  Created by GUANJIU ZHANG on 10/8/16.
//

import Foundation
import AVFoundation
import VideoToolbox

class cameraFrameProcessor: UIViewController {
    
    lazy var cameraSession: AVCaptureSession  = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetMedium
        return session
    }()
    
    let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo) as AVCaptureDevice
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview =  AVCaptureVideoPreviewLayer(session: self.cameraSession)
        preview.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        preview.position = CGPoint(x: CGRectGetMidX(self.view.bounds), y: CGRectGetMidY(self.view.bounds))
        preview.videoGravity = AVLayerVideoGravityResizeAspect
        return preview
    }()
    
    override func viewDidLoad() {
        self.configInputAndOutput()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.view.layer.addSublayer(previewLayer)
        cameraSession.startRunning()
    }
    
    override func viewDidAppear(animated: Bool) {
        let button = UIButton(type: .Custom)
        button.layer.cornerRadius = 8.0
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2.0
        button.frame = CGRectMake(0, 0, self.view.bounds.width/3, 44.0)
        button.center = CGPoint(x: CGRectGetMidX(self.view.bounds), y: self.previewLayer.frame.maxY - 32.0)
        button.setTitle("Close", forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        button.addTarget(self, action: #selector(self.buttonAction), forControlEvents: .TouchUpInside)
        self.view.addSubview(button)
    }
    
    func buttonAction(){
        self.cameraSession.stopRunning()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func configInputAndOutput(){
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            cameraSession.beginConfiguration() // 1
            
            if (cameraSession.canAddInput(deviceInput) == true) {
                cameraSession.addInput(deviceInput)
            }
            
            let dataOutput = AVCaptureVideoDataOutput() // 2
            
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(unsignedInt: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)] // 3
            
            dataOutput.alwaysDiscardsLateVideoFrames = true // 4
            
            if (cameraSession.canAddOutput(dataOutput) == true) {
                cameraSession.addOutput(dataOutput)
            }
            
            cameraSession.commitConfiguration() //5
            
            let queue = dispatch_queue_create("com.invasivecode.queue", DISPATCH_QUEUE_SERIAL) // 6
            dataOutput.setSampleBufferDelegate(self, queue: queue) // 7
            
        }
        catch let error as NSError {
            NSLog("\(error), \(error.localizedDescription)")
        }
    }
}

extension cameraFrameProcessor: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
        guard sampleBuffer != nil else {
            return
        }
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)! as CVPixelBufferRef
        let image_CI = CIImage(CVPixelBuffer: CMSampleBufferGetImageBuffer(sampleBuffer)! as CVPixelBufferRef)
        let context = CIContext(options: nil)
        let image_CG = context.createCGImage(
            image_CI,
            fromRect: CGRectMake(0, 0,
                CGFloat(CVPixelBufferGetWidth(pixelBuffer)),
                CGFloat(CVPixelBufferGetHeight(pixelBuffer)))
        )

        let image = OpenCVWrapper.processImageWithOpenCV(UIImage(CGImage: image_CG!)) //  Here you have UIImage
        print("did receive video frames... -> \(image)")
    }
}
