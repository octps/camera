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
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var stateLabel: UILabel!
    
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
        stateLabel.text = ""
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
            stateLabel.text = "recording"
            recordButton.setTitle("stop", forState: UIControlState.Normal)
        }
    }
    
    func onClickStopButton(sender: UIButton){
        if isRecording {
            fileOutput.stopRecording()
            
            isRecording = false
            stateLabel.text = ""
            recordButton.setTitle("start", forState: UIControlState.Normal)
        }
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        let assetsLib = ALAssetsLibrary()
        assetsLib.writeVideoAtPathToSavedPhotosAlbum(outputFileURL, completionBlock: nil)
    }
}
