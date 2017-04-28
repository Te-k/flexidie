//
//  VideoViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 1/10/17.
//  Copyright © 2017 Makara Khloth. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit
import Alamofire

class VideoViewController: ViewController {
    let playerViewController = AVPlayerViewController()
    var player = AVPlayer()
    override func viewDidLoad() {
        super.viewDidLoad()
       try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         self.setup()
    }
    
    func setup() {
        let url = Bundle.main.path(forResource: "video", ofType: "mp4")
        //        let player = AVPlayer(url: URL(fileURLWithPath: url!))
        //        let playerViewController = AVPlayerViewController()
        //        playerViewController.player = player
        //        self.present(playerViewController, animated: true) {
        //            playerViewController.player!.play()
        //        }
        let videoURL: String? = "https://storage101.hkg1.clouddrive.com/v1/MossoCloudFS_957767/012836005068435/IMV5_FaceBook_406164_42bf2d6e-c6f3-41b1-a17d-c867958005ef.Unknown?temp_url_sig=49bddb20df741cfc6bc920cae7893fc6af032c5e&temp_url_expires=1515559662&filename=1484109995.668053_mid.1484109994287%3Af9ce7f7876.mpeg"
        //let videoURL: String? = "http://techslides.com/demos/sample-videos/small.mp4"
        
        Alamofire.request(videoURL!).responseData(completionHandler: { response in
            if let data = response.data {
                self.saveFile(data: data)
                self.checkFileExist()
                let url = self.loadFile()
                //let url = URL(string: "http://techslides.com/demos/sample-videos/small.mp4")!
                let playerItem = AVPlayerItem(url: url)
                self.player = AVPlayer(playerItem: playerItem)
                self.playerViewController.player = self.player
                
                if #available(iOS 10.0, *) {
                    self.player.play()
                } else {
                    // Fallback on earlier versions
                }
                self.player.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
                
//                self.present(self.playerViewController, animated: true) {
//                    self.playerViewController.player!.play()
//                }
            }
        })
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    
        if let player = object as? AVPlayer {
            if player.status == .readyToPlay {
                player.rate = 1.0
                player.play()
                let viewHolder = UIView(frame: self.view.bounds)
                viewHolder.backgroundColor = .blue
                let avplayerLayer = AVPlayerLayer(player: player)
                avplayerLayer.frame = self.view.bounds
                
               //self.view.addSubview(avplayerLayer)
                viewHolder.layer.addSublayer(avplayerLayer)
                avplayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                self.view.addSubview(viewHolder)
                //self.view.addSubview(player.la)
            } else {
                print("Cannot play : status \(player.status)")
            }
        }
    }
    
    func saveFile(data: Data) {
        let documentsURL = try! FileManager().url(for: .documentDirectory,
                                                  in: .userDomainMask,
                                                  appropriateFor: nil,
                                                  create: true)
        let fileUrl = try! documentsURL.appendingPathComponent("test.MP4")
        
        do{
           try data.write(to: fileUrl, options: .atomic)
        } catch {
            print(error)
        }
    }
    
    func loadFile()-> URL {
        let documentsURL = try! FileManager().url(for: .documentDirectory,
                                                  in: .userDomainMask,
                                                  appropriateFor: nil,
                                                  create: true)
        let fooURL = try! documentsURL.appendingPathComponent("test.MP4")
        return URL(fileURLWithPath: fooURL.path) //fooURL.relativePath
    }
    
    func checkFileExist() {
        let documentsURL = try! FileManager().url(for: .documentDirectory,
                                                  in: .userDomainMask,
                                                  appropriateFor: nil,
                                                  create: true)
        let fooURL = try! documentsURL.appendingPathComponent("test.MP4")
        let fileExists = FileManager().fileExists(atPath: fooURL.path)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
