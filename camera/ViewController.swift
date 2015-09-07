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
    
    @IBOutlet weak var clipView1: UIImageView!
    @IBOutlet weak var clipView3: UIImageView!
    
    @IBAction func ClickStartClipButton(sender: AnyObject) {
        onClickStartClipButton(sender as! UIButton)
    }
    @IBAction func clearClipButton(sender: AnyObject) {
        onClickClearClipButton(sender as! UIButton)
    }
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var captureDevice : AVCaptureDevice?
    let fileOutput = AVCaptureMovieFileOutput()
    var isRecording = false
    var isClipPlaying = false
    
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
        showDefalutImage()
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
        if (!isRecording) {
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

    func showDefalutImage(){
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] as String
        let filePath : String? = "\(documentsDirectory)/temp.mp4"
        
        if (NSFileManager.defaultManager().fileExistsAtPath(filePath!)) {
            let fileURL : NSURL = NSURL(fileURLWithPath: filePath!)
            makeImageFromVideo(fileURL, id: 2)
        }
        else {
            let filePath1 = NSBundle.mainBundle().pathForResource("resource/1", ofType: "MOV")
            let fileURL1 : NSURL = NSURL(fileURLWithPath: filePath1!)
            makeImageFromVideo(fileURL1, id: 1)
            
            let filePath2 = NSBundle.mainBundle().pathForResource("resource/2", ofType: "MOV")
            let fileURL2 : NSURL = NSURL(fileURLWithPath: filePath2!)
            makeImageFromVideo(fileURL2, id: 2)

            let filePath3 = NSBundle.mainBundle().pathForResource("resource/3", ofType: "MOV")
            let fileURL3 : NSURL = NSURL(fileURLWithPath: filePath3!)
            makeImageFromVideo(fileURL3, id: 3)
        }
    }
    
    func makeImageFromVideo(fileURL: NSURL, id:Int) {
        let avAsset = AVURLAsset(URL: fileURL, options: nil)
        
        // assetから画像をキャプチャーする為のジュネレーターを生成.
        let generator = AVAssetImageGenerator(asset: avAsset)
        generator.maximumSize = self.view.frame.size
                
        // 静止画用のImageViewを生成.
        let image =  UIImage(CGImage: try! generator.copyCGImageAtTime(avAsset.duration, actualTime: nil))
        let rotateImage = UIImage(CGImage: image.CGImage!, scale: 1.0, orientation: UIImageOrientation.Right)
        if (id == 1) {
            clipView1.image = rotateImage
        }
        if (id == 2) {
            clipView.image = rotateImage
        }
        if (id == 3) {
            clipView3.image = rotateImage
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
    
    func onClickStartClipButton(sender: UIButton){
        print(sender.tag)
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] as String
        let filePath : String? = "\(documentsDirectory)/temp.mp4"
        
        if (NSFileManager.defaultManager().fileExistsAtPath(filePath!)) {
            selectMovie(filePath)
        }
        else {
            if (sender.tag == 1) {
                let filePath = NSBundle.mainBundle().pathForResource("resource/1", ofType: "MOV")
                selectMovie(filePath)
            }
            if (sender.tag == 2) {
                let filePath = NSBundle.mainBundle().pathForResource("resource/2", ofType: "MOV")
                selectMovie(filePath)
            }
            if (sender.tag == 3) {
                let filePath = NSBundle.mainBundle().pathForResource("resource/3", ofType: "MOV")
                selectMovie(filePath)
            }
        }
    }
    
    func onClickClearClipButton(sender: UIButton) {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] as String
        let filePath : String? = "\(documentsDirectory)/temp.mp4"

        if (NSFileManager.defaultManager().fileExistsAtPath(filePath!)) {
            try! NSFileManager.defaultManager().removeItemAtPath(filePath!)
        }
        showDefalutImage()
    }
    
    func selectMovie(filePath : String?) {
        let fileURL : NSURL = NSURL(fileURLWithPath: filePath!)
        
        let avAsset = AVURLAsset(URL: fileURL, options: nil)
        
        playerItem = AVPlayerItem(asset: avAsset)
        videoPlayer = AVPlayer(playerItem: playerItem)
        showMovie(videoPlayer)
    }
    
    func showMovie(videoPlayer : AVPlayer?) {
        if (isClipPlaying == false) {
//            let fileURL : NSURL = NSURL(fileURLWithPath: filePath!)
//
//            let avAsset = AVURLAsset(URL: fileURL, options: nil)
//
//            playerItem = AVPlayerItem(asset: avAsset)
//            videoPlayer = AVPlayer(playerItem: playerItem)
            let videoPlayerView = AVPlayerView(frame: self.view.bounds)
            
            myLayer = videoPlayerView.layer as! AVPlayerLayer
            myLayer.videoGravity = AVLayerVideoGravityResizeAspect
            myLayer.player = videoPlayer

            let sereenWidth = self.view.bounds.width
            let sereenHeight = (self.view.bounds.height) + 90
            self.view.layer.insertSublayer(myLayer!, atIndex:1)
            myLayer?.frame = CGRectMake(0, 0, sereenWidth, sereenHeight)
        }
        myLayer.player = videoPlayer
        startMovie()
    }

    func startMovie() {
        /* 動画の終了を監視 */
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidPlayToEndTime:",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: self.playerItem)
        isClipPlaying = true
        videoPlayer.seekToTime(kCMTimeZero)
        videoPlayer.play()
    }

    func playerDidPlayToEndTime(notification: NSNotification) {
        isClipPlaying = false
        myLayer?.removeFromSuperlayer()
    }

    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        
        makeImageFromVideo(outputFileURL, id:1)
        
        let assetsLib = ALAssetsLibrary()
        assetsLib.writeVideoAtPathToSavedPhotosAlbum(outputFileURL, completionBlock: nil)
        
    }
    
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
