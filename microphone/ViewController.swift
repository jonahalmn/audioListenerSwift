//
//  ViewController.swift
//  microphone
//
//  Created by Jonah Alle Monne on 22/03/2018.
//  Copyright © 2018 Jonah Alle Monne. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {
    
    var recordingSession: AVAudioSession!
    var whistleRecorder: AVAudioRecorder!
    var success = true
    var player = SoundPlayer()
    var timer : Timer!
    
    
    @IBOutlet weak var meter: UIView!
    
    @IBOutlet weak var status: UILabel!
    
    var analyser = SoundAnalyzer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        self.loadFailUI()
                    }
                }
            }
        } catch {
            self.loadFailUI()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    class func getFileURL() -> URL {
        return getDocumentsDirectory().appendingPathComponent("file.m4a")
    }

    func loadRecordingUI() {
        print("Record")
    }
    
    func loadFailUI() {
        print("Not Record")
    }
    
    @IBAction func startAnalysis(_ sender: Any) {
        analyser.initialization()
    }
    
    @IBAction func startRecord(_ sender: Any) {
        
        let audioUrl = ViewController.getFileURL()
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            // 5
            whistleRecorder = try AVAudioRecorder(url: audioUrl, settings: settings)
            whistleRecorder.isMeteringEnabled = true
            whistleRecorder.delegate = self
            whistleRecorder.record()
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(callbackRecord), userInfo: nil, repeats: true)
            print("recording")
        } catch {
            stopRecording(success: false)
        }
        
    }
    
    @objc func callbackRecord() -> Void {
        whistleRecorder.updateMeters()
        print(whistleRecorder.averagePower(forChannel: 0))
        meter.bounds.size.height = CGFloat((whistleRecorder.averagePower(forChannel: 0)) + 50)
    }
    
    @IBAction func stopRecord(_ sender: Any) {
        timer.invalidate()
        stopRecording(success: true)
    }

    @IBAction func playRecorded(_ sender: Any) {
        player.playSound(url: ViewController.getFileURL())
    }
    
    func stopRecording(success: Bool){
        whistleRecorder.stop()
        whistleRecorder = nil
        
        if success {
            print("recorded")
        } else {
            let ac = UIAlertController(title: "Record failed", message: "There was a problem recording your whistle; please try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    

}

