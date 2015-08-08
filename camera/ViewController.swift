//
//  ViewController.swift
//  camera
//
//  Created by n001 on 2015/06/23.
//  Copyright © 2015年 n001. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    @IBAction func ClickStartButton(sender: AnyObject) {
        onClickStartButton(sender as! UIButton)
    }
    
    @IBAction func ClickStopButton(sender: AnyObject) {
        onClickStopButton(sender as! UIButton)
    }
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var captureDevice : AVCaptureDevice?
    let fileOutput = AVCaptureMovieFileOutput()
    var isRecording = false

    override func viewDidLoad() {
        super.viewDidLoad()
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // 背面カメラあるかどうか。ここを調整して全面カメラにしたりもできる
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        print("背面カメラ発見しました。")
                        beginCamera()
                    }
                }
            }
        }
    }
    
    //カメラ設定
    func configureDevice() {
        if let device = captureDevice {
            do {
                 try device.lockForConfiguration()
            }
            catch {
                print(error)
            }
            device.focusMode = .Locked
            device.unlockForConfiguration()
        }
    }
    
    //カメラ開始！
    func beginCamera() {
        configureDevice()
        let err : NSError? = nil
        do {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
            captureSession.addOutput(fileOutput)
        } catch {
            print(err)
        }
        
        if err != nil {
            print("エラー: \(err?.localizedDescription)")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer!)
        previewLayer?.frame = CGRectMake(10, 20, 300, 300)
        captureSession.startRunning()
    }
    
    func onClickStartButton(sender: UIButton){
        if !isRecording {
            // start recording
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let documentsDirectory = paths[0] as String
            let filePath : String? = "\(documentsDirectory)/temp.mp4"
            let fileURL : NSURL = NSURL(fileURLWithPath: filePath!)

            if (NSFileManager.defaultManager().fileExistsAtPath(filePath!)) {
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(filePath!)
                } catch {
                    print("error")
                }
            }
            fileOutput.startRecordingToOutputFileURL(fileURL, recordingDelegate: self)
            
            isRecording = true
            
//            self.changeButtonColor(self.startButton, color: UIColor.grayColor())
//            self.changeButtonColor(self.stopButton, color: UIColor.redColor())
        }
    }
    
    func onClickStopButton(sender: UIButton){
        if isRecording {
            fileOutput.stopRecording()
            
            isRecording = false
//            self.changeButtonColor(self.startButton, color: UIColor.redColor())
//            self.changeButtonColor(self.stopButton, color: UIColor.grayColor())
        }
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        let assetsLib = ALAssetsLibrary()
        assetsLib.writeVideoAtPathToSavedPhotosAlbum(outputFileURL, completionBlock: nil)
    }
}

//class ViewController: UIViewController {
//    
//    var stillImageOutput: AVCaptureStillImageOutput!
//    var session: AVCaptureSession!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//        
//        // Start Camera
//        self.configureCamera()
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    func configureCamera() -> Bool {
//        // init camera device
//        var captureDevice: AVCaptureDevice?
//        let devices: NSArray = AVCaptureDevice.devices()
//        
//        // find back camera
//        for device: AnyObject in devices {
//            if device.position == AVCaptureDevicePosition.Back {
//                captureDevice = device as? AVCaptureDevice
//            }
//        }
//        
//        if (captureDevice != nil) {
//            // Debug
//            print(captureDevice!.localizedName)
//            print(captureDevice!.modelID)
//        } else {
//            print("Missing Camera")
//            return false
//        }
//        
//        
//
//       // let error:NSError?
//        
//        do {
//            let deviceInput:AVCaptureDeviceInput = try AVCaptureDeviceInput(device: captureDevice) as AVCaptureDeviceInput
//            self.stillImageOutput = AVCaptureStillImageOutput()
//            
//            // init session
//            self.session = AVCaptureSession()
//            self.session.sessionPreset = AVCaptureSessionPresetPhoto
//            self.session.addInput(deviceInput as AVCaptureInput)
//            self.session.addOutput(self.stillImageOutput)
//
//        } catch let error as NSError {
//            print(error)
//        }
//        
//        // init device input
////        var error: NSErrorPointer!
////        var deviceInput: AVCaptureInput = AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: error) as AVCaptureInput
//        
//        
//        // layer for preview
//        let previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(self.session)
//        previewLayer.frame = self.view.bounds
//        self.view.layer.addSublayer(previewLayer)
//        
//        self.session.startRunning()
//        
//        return true
//    }
//    
//}