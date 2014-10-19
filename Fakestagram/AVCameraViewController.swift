//
//  AVCameraViewController.swift
//  Fakestagram
//
//  Created by Casey R White on 10/18/14.
//  Copyright (c) 2014 casecode. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia
import CoreVideo
import ImageIO
import QuartzCore

class AVCameraViewController: UIViewController {
    
    @IBOutlet weak var capturePreviewImageButton: UIButton!
    @IBOutlet weak var selectImageButton: UIButton!
    
    let captureSession = AVCaptureSession()
    var stillImageOutput = AVCaptureStillImageOutput()
    var delegate: ImageSelectorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        previewLayer.frame = CGRectMake(0, 64, self.view.frame.size.width, CGFloat(self.view.frame.size.height - 250))
        self.view.layer.addSublayer(previewLayer)
        
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error: NSError?
        let input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error) as AVCaptureDeviceInput!
        
        if input == nil {
            println("AV Camera input not available on this device")
        }
        
        self.captureSession.addInput(input)
        let outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
        self.stillImageOutput.outputSettings = outputSettings
        self.captureSession.addOutput(self.stillImageOutput)
        self.captureSession.startRunning()
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }
    
    
    @IBAction func capturePressed(sender: AnyObject) {
        
        var videoConnection: AVCaptureConnection?
        for connection in self.stillImageOutput.connections {
            if let cameraConnection = connection as? AVCaptureConnection {
                for port in cameraConnection.inputPorts {
                    if let videoPort = port as? AVCaptureInputPort {
                        if videoPort.mediaType == AVMediaTypeVideo {
                            videoConnection = cameraConnection
                            break
                        }
                    }
                }
            }
            if videoConnection != nil {
                break
            }
        }
        
        self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(buffer : CMSampleBuffer!, error : NSError!) -> Void in
            var data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
            var image = UIImage(data: data)
            self.capturePreviewImageButton.setImage(image, forState: UIControlState.Normal)
        })
    }
    
    @IBAction func previewImageSelected(sender: AnyObject) {
        if let previewImage = self.capturePreviewImageButton.imageView?.image {
            self.delegate?.imageSelected(previewImage)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
