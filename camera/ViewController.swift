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
        
    @IBOutlet weak var clipView: UIImageView!
    @IBOutlet weak var clipButton: UIButton!
    
    @IBAction func ClickStartClipButton(sender: AnyObject) {
        onClickStartClipButton(sender as! UIButton)
    }
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var captureDevice : AVCaptureDevice?
    let fileOutput = AVCaptureMovieFileOutput()
    var isRecording = false
    var isLooping = false
    
    var playerItem : AVPlayerItem!
    var videoPlayer : AVPlayer!
    var myLayer : AVPlayerLayer!
    
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
        let sereenWidth = self.view.bounds.width
        let sereenHeight = (self.view.bounds.height) + 90
        self.view.layer.insertSublayer(previewLayer!, atIndex:0)
        previewLayer?.frame = CGRectMake(0, 0, sereenWidth, sereenHeight)
        
        captureSession.startRunning()
    }
    
    func onClickStartButton(sender: UIButton){
        if (!isRecording && !isLooping) {
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
//        if (!isRecording && isLooping) {
//            myLayer?.removeFromSuperlayer()
//            //bigin camera
//            captureSession.startRunning()
//
//            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//            let sereenWidth = self.view.bounds.width
//            let sereenHeight = (self.view.bounds.height) + 90
//            self.view.layer.insertSublayer(previewLayer!, atIndex:0)
//            previewLayer?.frame = CGRectMake(0, 0, sereenWidth, sereenHeight)
//        }
    }
    
    func makeImageFromVideo(fileURL: NSURL) {
        let avAsset = AVURLAsset(URL: fileURL, options: nil)
        
        // assetから画像をキャプチャーする為のジュネレーターを生成.
        let generator = AVAssetImageGenerator(asset: avAsset)
        generator.maximumSize = self.view.frame.size
                
        // 静止画用のImageViewを生成.
        let image =  UIImage(CGImage: try! generator.copyCGImageAtTime(avAsset.duration, actualTime: nil))
        let rotateImage = UIImage(CGImage: image.CGImage!, scale: 1.0, orientation: UIImageOrientation.Right)
        clipView.image = rotateImage
    }
    
    func onClickStopButton(sender: UIButton){
        if isRecording {
            fileOutput.stopRecording()
            isRecording = false
            stateLabel.text = ""
            recordButton.setTitle("start", forState: UIControlState.Normal)
            
        }
    }
    
    func onClickStartClipButton(sender: UIButton){
        print("clipButton")
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        
//        // カメラとのセッションを削除
//        self.captureSession.stopRunning()
//        //        for output in self.captureSession.outputs {
//        //            self.captureSession.removeOutput(output as! AVCaptureOutput)
//        //        }
//        //
//        //        for input in self.captureSession.inputs {
//        //            self.captureSession.removeInput(input as! AVCaptureInput)
//        //        }
//        ////        self.captureSession = nil
//        ////        self.device = nil
//        
//        // showVideo
//        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
//        let documentsDirectory = paths[0] as String
//        let filePath : String? = "\(documentsDirectory)/temp.mp4"
//        let fileURL : NSURL = NSURL(fileURLWithPath: filePath!)
//        
//        previewLayer?.removeFromSuperlayer()
//        
//        let avAsset = AVURLAsset(URL: fileURL, options: nil)
//        
//        playerItem = AVPlayerItem(asset: avAsset)
//        videoPlayer = AVPlayer(playerItem: playerItem)
//        let videoPlayerView = AVPlayerView(frame: self.view.bounds)
//        
//        myLayer = videoPlayerView.layer as! AVPlayerLayer
//        myLayer.videoGravity = AVLayerVideoGravityResizeAspect
//        myLayer.player = videoPlayer
//        
//        let sereenWidth = self.view.bounds.width
//        let sereenHeight = (self.view.bounds.height) + 90
//        self.view.layer.insertSublayer(myLayer!, atIndex:0)
//        myLayer?.frame = CGRectMake(0, 0, sereenWidth, sereenHeight)
//        
//        startMovie()
//        
        //wirte video
        makeImageFromVideo(outputFileURL)
        
        let assetsLib = ALAssetsLibrary()
        assetsLib.writeVideoAtPathToSavedPhotosAlbum(outputFileURL, completionBlock: nil)
        
    }
    
//    func startMovie() {
//        /* 動画の終了を監視 */
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidPlayToEndTime:",
//            name: AVPlayerItemDidPlayToEndTimeNotification,
//            object: self.playerItem)
//        videoPlayer.seekToTime(kCMTimeZero)
//        //        videoPlayer.seekToTime(CMTimeMakeWithSeconds(0, Int32(NSEC_PER_SEC)))
//        videoPlayer.play()
//        recordButton.setTitle("return camera", forState: UIControlState.Normal)
//        isLooping = true
//    }
//    
//    func playerDidPlayToEndTime(notification: NSNotification) {
//        repeatMovie()
//    }
//    
//    func repeatMovie() {
//        videoPlayer.seekToTime(kCMTimeZero)
//        videoPlayer.play()
//    }
    
}


class AVPlayerView : UIView{
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override class func layerClass() -> AnyClass{
        return AVPlayerLayer.self
    }
    
}
