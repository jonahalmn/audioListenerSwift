//
//  SoundAnalyzer.swift
//  microphone
//
//  Created by Jonah Alle Monne on 22/03/2018.
//  Copyright © 2018 Jonah Alle Monne. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit
import Accelerate


class SoundAnalyzer {
    
    let audioEngine = AVAudioEngine()
    let audioNode = AVAudioPlayerNode()

    
     func initialization() -> Void {
        self.audioEngine.attach(audioNode)
        
        let url = ViewController.getFileURL()
        guard let audioFile = try? AVAudioFile(forReading: url) else { return }
        
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat,
                                      frameCapacity: AVAudioFrameCount(audioFile.length))
        try? audioFile.read(into: buffer!)
        audioEngine.connect(audioNode, to: audioEngine.mainMixerNode, format: buffer?.format)
        audioNode.scheduleBuffer(buffer!, at: nil, options: .loops, completionHandler: nil)
        
        let size: UInt32 = 1024
        let mixerNode = audioEngine.mainMixerNode
        
        mixerNode.installTap(onBus: 0,
                             bufferSize: size,
                             format: mixerNode.outputFormat(forBus: 0)) { (buffer, time) in
                               // performFFT(buffer: buffer)
                                print(mixerNode)
        }
    }
    
    func performFFT(buffer: AVAudioPCMBuffer) {
        let frameCount = buffer.frameLength
        let log2n = UInt(round(log2(Double(frameCount))))
        let bufferSizePOT = Int(1 << log2n)
        let inputCount = bufferSizePOT / 2
        let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))
        
        var realp = [Float](repeating: 0, count: inputCount)
        var imagp = [Float](repeating: 0, count: inputCount)
        var output = DSPSplitComplex(realp: &realp, imagp: &imagp)
        
        let windowSize = bufferSizePOT
        var transferBuffer = [Float](repeating: 0, count: windowSize)
        var window = [Float](repeating: 0, count: windowSize)
        
        // Hann windowing to reduce the frequency leakage
        vDSP_hann_window(&window, vDSP_Length(windowSize), Int32(vDSP_HANN_NORM))
        vDSP_vmul((buffer.floatChannelData?.pointee)!, 1, window,
                  1, &transferBuffer, 1, vDSP_Length(windowSize))
        
        // Transforming the [Float] buffer into a UnsafePointer<Float> object for the vDSP_ctoz method
        // And then pack the input into the complex buffer (output)
        let temp = UnsafePointer<Float>(transferBuffer)
        temp.withMemoryRebound(to: DSPComplex.self,
                               capacity: transferBuffer.count) {
                                vDSP_ctoz($0, 2, &output, 1, vDSP_Length(inputCount))
        }
        
        // Perform the FFT
        vDSP_fft_zrip(fftSetup!, &output, 1, log2n, FFTDirection(FFT_FORWARD))
        
        var magnitudes = [Float](repeating: 0.0, count: inputCount)
        vDSP_zvmags(&output, 1, &magnitudes, 1, vDSP_Length(inputCount))
        
        // Normalising
        var normalizedMagnitudes = [Float](repeating: 0.0, count: inputCount)
//        vDSP_vsmul(sqrtq(magnitudes), 1, [2.0 / Float(inputCount)],
//                   &normalizedMagnitudes, 1, vDSP_Length(inputCount))
//
//        self.magnitudes = magnitudes
        vDSP_destroy_fftsetup(fftSetup)
    }
    
    
}
