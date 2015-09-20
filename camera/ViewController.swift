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
//    var isClipPlaying = false
    
    var playerItem1 : AVPlayerItem!
    var playerItem2 : AVPlayerItem!
    var playerItem3 : AVPlayerItem!
    
    var videoPlayer1 : AVPlayer!
    var videoPlayer2 : AVPlayer!
    var videoPlayer3 : AVPlayer!
    
    var myLayer1 : AVPlayerLayer!
    var myLayer2 : AVPlayerLayer!
    var myLayer3 : AVPlayerLayer!
    
    var videoPlayerView1 : AVPlayerView!
    var videoPlayerView2 : AVPlayerView!
    var videoPlayerView3 : AVPlayerView!
    
    var movieNumber : Int!
    
    var filePath : String!

    var AudioInput : AVCaptureDeviceInput!
   
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
        movieNumber = 0
        showDefalutImage()
        setDefaultMovie()
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
            let captureDeviceAudio = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
            
            do {
                AudioInput = try AVCaptureDeviceInput(device: captureDeviceAudio) as AVCaptureDeviceInput
            } catch {
                print("audioerror")
            }

            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
            captureSession.addInput(AudioInput)
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
    
    func onClickStartButton(sender: UIButton) {
        if (!isRecording) {
            // start recording
            
            movieNumber = movieNumber + 1
            if (movieNumber == 4) {
                movieNumber = 1
            }
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let documentsDirectory = paths[0] as String
            
            if (movieNumber == 1) {
                filePath = "\(documentsDirectory)/temp1.mp4"
                if (NSFileManager.defaultManager().fileExistsAtPath(filePath!)) {
                    do {
                        try NSFileManager.defaultManager().removeItemAtPath(filePath!)
                    } catch {
                        print("error")
                    }
                }
            }
            
            if (movieNumber == 2) {
                filePath = "\(documentsDirectory)/temp2.mp4"
                if (NSFileManager.defaultManager().fileExistsAtPath(filePath!)) {
                    do {
                        try NSFileManager.defaultManager().removeItemAtPath(filePath!)
                    } catch {
                        print("error")
                    }
                }
            }
            
            if (movieNumber == 3) {
                filePath = "\(documentsDirectory)/temp3.mp4"
                if (NSFileManager.defaultManager().fileExistsAtPath(filePath!)) {
                    do {
                        try NSFileManager.defaultManager().removeItemAtPath(filePath!)
                    } catch {
                        print("error")
                    }
                }
            }
            let fileURL : NSURL = NSURL(fileURLWithPath: filePath)
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
    
    func setDefaultMovie() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] as String
        let filePath : String? = "\(documentsDirectory)/temp.mp4"
        
        if (NSFileManager.defaultManager().fileExistsAtPath(filePath!)) {
            setDefaultAsset(filePath!, id:2)
        }
        else {
            let filePath1 = NSBundle.mainBundle().pathForResource("resource/1", ofType: "MOV")
            setDefaultAsset(filePath1!, id:1)
            let filePath2 = NSBundle.mainBundle().pathForResource("resource/2", ofType: "MOV")
            setDefaultAsset(filePath2!, id:2)
            let filePath3 = NSBundle.mainBundle().pathForResource("resource/3", ofType: "MOV")
            setDefaultAsset(filePath3!, id:3)
        }
    }
    
    func setDefaultAsset(filePath: String, id:Int){
        let fileURL : NSURL = NSURL(fileURLWithPath: filePath)
        let avAsset = AVURLAsset(URL: fileURL, options: nil)
        
        if (id == 1) {
            print(1)
            playerItem1 = AVPlayerItem(asset: avAsset)
            videoPlayer1 = AVPlayer(playerItem: playerItem1)
            videoPlayerView1 = AVPlayerView(frame: self.view.bounds)
            
            myLayer1 = videoPlayerView1.layer as! AVPlayerLayer
            myLayer1.videoGravity = AVLayerVideoGravityResizeAspect
            myLayer1.player = videoPlayer1
            
            let sereenWidth = self.view.bounds.width
            let sereenHeight = (self.view.bounds.height) + 90
            self.view.layer.insertSublayer(myLayer1!, atIndex:2)
            myLayer1?.frame = CGRectMake(0, 0, sereenWidth, sereenHeight)
            self.view.sendSubviewToBack(videoPlayerView1)
        }
        if (id == 2) {
            print(2)
            playerItem2 = AVPlayerItem(asset: avAsset)
            videoPlayer2 = AVPlayer(playerItem: playerItem2)
            videoPlayerView2 = AVPlayerView(frame: self.view.bounds)
            
            myLayer2 = videoPlayerView2.layer as! AVPlayerLayer
            myLayer2.videoGravity = AVLayerVideoGravityResizeAspect
            myLayer2.player = videoPlayer2
            
            let sereenWidth = self.view.bounds.width
            let sereenHeight = (self.view.bounds.height) + 90
            self.view.layer.insertSublayer(myLayer2!, atIndex:3)
            myLayer2?.frame = CGRectMake(0, 0, sereenWidth, sereenHeight)
            self.view.sendSubviewToBack(videoPlayerView2)
        }
        if (id == 3) {
            print(3)
            playerItem3 = AVPlayerItem(asset: avAsset)
            videoPlayer3 = AVPlayer(playerItem: playerItem3)
            videoPlayerView3 = AVPlayerView(frame: self.view.bounds)
            
            myLayer3 = videoPlayerView3.layer as! AVPlayerLayer
            myLayer3.videoGravity = AVLayerVideoGravityResizeAspect
            myLayer3.player = videoPlayer3
            
            let sereenWidth = self.view.bounds.width
            let sereenHeight = (self.view.bounds.height) + 90
            self.view.layer.insertSublayer(myLayer3!, atIndex:4)
            myLayer3?.frame = CGRectMake(0, 0, sereenWidth, sereenHeight)
            self.view.sendSubviewToBack(videoPlayerView3)
        }
    }
    
    func onClickStartClipButton(sender: UIButton){
        if (sender.tag == 1) {
            self.view.layer.insertSublayer(myLayer1!, atIndex:4)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidPlayToEndTime1:",
                name: AVPlayerItemDidPlayToEndTimeNotification,
                object: self.playerItem1)
            videoPlayer1.seekToTime(kCMTimeZero)
            videoPlayer1.play()

        }
        if (sender.tag == 2) {
            self.view.layer.insertSublayer(myLayer2!, atIndex:4)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidPlayToEndTime2:",
                name: AVPlayerItemDidPlayToEndTimeNotification,
                object: self.playerItem2)
            videoPlayer2.seekToTime(kCMTimeZero)
            videoPlayer2.play()

        }
        if (sender.tag == 3) {
            self.view.layer.insertSublayer(myLayer3!, atIndex:4)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidPlayToEndTime3:",
                name: AVPlayerItemDidPlayToEndTimeNotification,
                object: self.playerItem3)
            videoPlayer3.seekToTime(kCMTimeZero)
            videoPlayer3.play()
        }
    }
    
    func playerDidPlayToEndTime1(notification: NSNotification) {
        videoPlayer1.seekToTime(kCMTimeZero)
        self.view.sendSubviewToBack(videoPlayerView1)
    }
    
    func playerDidPlayToEndTime2(notification: NSNotification) {
        videoPlayer2.seekToTime(kCMTimeZero)
        self.view.sendSubviewToBack(videoPlayerView2)
    }
    
    func playerDidPlayToEndTime3(notification: NSNotification) {
        videoPlayer3.seekToTime(kCMTimeZero)
        self.view.sendSubviewToBack(videoPlayerView3)
    }

    func onClickClearClipButton(sender: UIButton) {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] as String
//        let filePath : String? = "\(documentsDirectory)/temp.mp4"
        let filePath1 : String? = "\(documentsDirectory)/temp1.mp4"
        let filePath2 : String? = "\(documentsDirectory)/temp2.mp4"
        let filePath3 : String? = "\(documentsDirectory)/temp3.mp4"

//        if (NSFileManager.defaultManager().fileExistsAtPath(filePath!)) {
//            try! NSFileManager.defaultManager().removeItemAtPath(filePath!)
//        }
        if (NSFileManager.defaultManager().fileExistsAtPath(filePath1!)) {
            try! NSFileManager.defaultManager().removeItemAtPath(filePath1!)
        }
        if (NSFileManager.defaultManager().fileExistsAtPath(filePath2!)) {
            try! NSFileManager.defaultManager().removeItemAtPath(filePath2!)
        }
        if (NSFileManager.defaultManager().fileExistsAtPath(filePath3!)) {
            try! NSFileManager.defaultManager().removeItemAtPath(filePath3!)
        }
        
        movieNumber = 0
        showDefalutImage()
        returnDefaultMovie()
    }
    
    func returnDefaultMovie() {
        let filePath1 = NSBundle.mainBundle().pathForResource("resource/1", ofType: "MOV")
        let fileURL1 : NSURL = NSURL(fileURLWithPath: filePath1!)
        let avAsset1 = AVURLAsset(URL: fileURL1, options: nil)
        playerItem1 = AVPlayerItem(asset: avAsset1)
        videoPlayer1 = AVPlayer(playerItem: playerItem1)
        myLayer1.player = videoPlayer1
        
        let filePath2 = NSBundle.mainBundle().pathForResource("resource/2", ofType: "MOV")
        let fileURL2 : NSURL = NSURL(fileURLWithPath: filePath2!)
        let avAsset2 = AVURLAsset(URL: fileURL2, options: nil)
        playerItem2 = AVPlayerItem(asset: avAsset2)
        videoPlayer2 = AVPlayer(playerItem: playerItem2)
        myLayer2.player = videoPlayer2

        let filePath3 = NSBundle.mainBundle().pathForResource("resource/3", ofType: "MOV")
        let fileURL3 : NSURL = NSURL(fileURLWithPath: filePath3!)
        let avAsset3 = AVURLAsset(URL: fileURL3, options: nil)
        playerItem3 = AVPlayerItem(asset: avAsset3)
        videoPlayer3 = AVPlayer(playerItem: playerItem3)
        myLayer3.player = videoPlayer3
    }
    
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {

        if (movieNumber == 1) {
            makeImageFromVideo(outputFileURL, id:1)
            let avAsset = AVURLAsset(URL: outputFileURL, options: nil)
            playerItem1 = AVPlayerItem(asset: avAsset)
            videoPlayer1 = AVPlayer(playerItem: playerItem1)
//            videoPlayerView1 = AVPlayerView(frame: self.view.bounds)
            myLayer1 = videoPlayerView1.layer as! AVPlayerLayer
            myLayer1.videoGravity = AVLayerVideoGravityResizeAspect
            myLayer1.player = videoPlayer1
        }

        if (movieNumber == 2) {
            makeImageFromVideo(outputFileURL, id: 2)
            let avAsset = AVURLAsset(URL: outputFileURL, options: nil)
            playerItem2 = AVPlayerItem(asset: avAsset)
            videoPlayer2 = AVPlayer(playerItem: playerItem2)
//            videoPlayerView2 = AVPlayerView(frame: self.view.bounds)
            myLayer2 = videoPlayerView2.layer as! AVPlayerLayer
            myLayer2.videoGravity = AVLayerVideoGravityResizeAspect
            myLayer2.player = videoPlayer2
        }

        if (movieNumber == 3) {
            makeImageFromVideo(outputFileURL, id:3)
            let avAsset = AVURLAsset(URL: outputFileURL, options: nil)
            playerItem3 = AVPlayerItem(asset: avAsset)
            videoPlayer3 = AVPlayer(playerItem: playerItem3)
//            videoPlayerView3 = AVPlayerView(frame: self.view.bounds)
            myLayer3 = videoPlayerView3.layer as! AVPlayerLayer
            myLayer3.videoGravity = AVLayerVideoGravityResizeAspect
            myLayer3.player = videoPlayer3

        }

//        let assetsLib = ALAssetsLibrary()
//        assetsLib.writeVideoAtPathToSavedPhotosAlbum(outputFileURL, completionBlock: nil)
        
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
