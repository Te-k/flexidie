//
//  AudioViewController.swift
//  Hydra
//
//  Created by Chanin Nokpet on 1/12/17.
//  Copyright © 2017 Makara Khloth. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit
import Alamofire

class AudioViewController: ViewController {

    var playerViewController = AVAudioPlayer()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func setup() {
        let audioUrl: String? = "https://ia802508.us.archive.org/5/items/testmp3testfile/mpthreetest.mp3"
        
        //let videoURL: String? = "http://techslides.com/demos/sample-videos/small.mp4"
        
        Alamofire.request(audioUrl!).responseData(completionHandler: { response in
            if let data = response.data {
                self.saveFile(data: data)
                self.checkFileExist()
                let url = self.loadFile()
                //let url = URL(string: "http://www.stephaniequinn.com/Music/Vivaldi%20-%20Spring%20from%20Four%20Seasons.mp3")!
                //let player = AVPlayer(url: url)
                
                do {
                    self.playerViewController = try AVAudioPlayer(data: data, fileTypeHint: AVFileTypeMPEGLayer3)
                    self.playerViewController.prepareToPlay()
                    self.playerViewController.play()
                } catch {
                    print(error)
                }
                
                self.playerViewController.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
                
//                self.present(self.playerViewController, animated: true) {
//                    self.playerViewController.player!.play()
//                }
            }
        })
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if let player = object as? AVAudioPlayer {
                player.play()
        }
    }
    
    func saveFile(data: Data) {
        let documentsURL = try! FileManager().url(for: .documentDirectory,
                                                  in: .userDomainMask,
                                                  appropriateFor: nil,
                                                  create: true)
        let fileUrl = try! documentsURL.appendingPathComponent("test.mp3")
        
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
        let fooURL = try! documentsURL.appendingPathComponent("test.mp3")
        return URL(fileURLWithPath: fooURL.path) //fooURL.relativePath
    }
    
    func checkFileExist() {
        let documentsURL = try! FileManager().url(for: .documentDirectory,
                                                  in: .userDomainMask,
                                                  appropriateFor: nil,
                                                  create: true)
        let fooURL = try! documentsURL.appendingPathComponent("test.mp3")
        let fileExists = FileManager().fileExists(atPath: fooURL.path)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
