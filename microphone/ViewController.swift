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
    var game = Game()
    var elapsedTime : Timer!
    var currentTime = 0.0
    var starter : Timer!
    var countDown = 3
    
    @IBOutlet weak var hint: UILabel!
    
    @IBOutlet weak var meter: UIView!
    @IBOutlet weak var startView: UIView!
    @IBOutlet weak var endView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
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
    
    func startChrono(){
         elapsedTime = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        currentTime += 0.1
        timeLabel.text = String(currentTime) + "s"
    }
    
    func stopChrono(){
        elapsedTime.invalidate()
    }
    
    func loadFailUI() {
        print("Not Record")
    }
    
    @IBAction func startAnalysis(_ sender: Any) {
        analyser.initialization()
    }
    
    func startRace(){
        game.startGame()
        startChrono()
    }
    
    @IBAction func startMoving(_ sender: Any) {
        starter = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
    }
    
    func startPlaying(){
        startRace()
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
    
    @objc func countdown(){
        print(self.countDown)
        if(countDown > 1){
            self.countDown -= 1
            setHintUI(text: String(countDown))
        }else{
            starter.invalidate()
            startPlaying()
            setHintUI(text: "Go!!!")
        }
    }
    
    func setHintUI(text : String){
        hint.text = text
    }
    
    @objc func callbackRecord() -> Void {
        whistleRecorder.updateMeters()
        print(whistleRecorder.averagePower(forChannel: 0))
        if (whistleRecorder.averagePower(forChannel: 0) > -10 && game.status == .ongoing){
            game.goForward()
            updateGameUI()
        }else if(game.status == .over){
            hint.text = "Fini!"
            timer.invalidate()
            stopChrono()
            stopRecording(success: true)
            game.status = .ready
        }
    }
    
    func updateGameUI(){
        let max = endView.frame.minY
        let min = startView.frame.minY
        
        print(min)
        
        meter.frame.origin.y = CGFloat(min - (((min - max)/100) * CGFloat(game.currentProgress)))
        //meter.bounds.size.height = CGFloat((whistleRecorder.averagePower(forChannel: 0)) + 50)
    }
    
    @IBAction func stopRecord(_ sender: Any) {
        timer.invalidate()
        stopRecording(success: true)
    }

    @IBAction func playRecorded(_ sender: Any) {
        player.playSound(url: ViewController.getFileURL())
    }
    
    func stopRecording(success: Bool){
        if (whistleRecorder !== nil){
        whistleRecorder.stop()
        whistleRecorder = nil
        }
        
        if success {
            print("recorded")
        } else {
            let ac = UIAlertController(title: "Record failed", message: "There was a problem recording your whistle; please try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    

}

