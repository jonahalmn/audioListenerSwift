//
//  SoundPlayer.swift
//  microphone
//
//  Created by Jonah Alle Monne on 22/03/2018.
//  Copyright © 2018 Jonah Alle Monne. All rights reserved.
//

import Foundation
import AVFoundation

class SoundPlayer {
    
    //var audioplayer : AVAudioPlayer?
     var timer : Timer!
    
     var audioPlayer :AVAudioPlayer?
    
     func playSound(url : URL) -> Void {
        let alertSound = url
        print(alertSound)
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        try! audioPlayer = AVAudioPlayer(contentsOf: alertSound)
        audioPlayer!.prepareToPlay()
        audioPlayer!.play()
        audioPlayer!.isMeteringEnabled = true
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(callbackValue), userInfo: nil, repeats: true)
        
    }
    
    @objc func callbackValue() -> Void {
        audioPlayer!.updateMeters()
        print(audioPlayer!.averagePower(forChannel: 0))
    }
}
