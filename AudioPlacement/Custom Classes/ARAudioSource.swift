//
//  ARAudioSource.swift
//  AudioPlacement
//
//  Created by Majid Alturki on 7/8/19.
//  Copyright © 2019 Majid Alturki. All rights reserved.
//

import Foundation
import ARKit
import AVFoundation

class ARAudioSource: ARAudioNode {
    
    var loop = true
    let audioPlayer = AVAudioPlayerNode()
    fileprivate var audioBuffer: AVAudioPCMBuffer!
    fileprivate let sceneWithCubeRoot = SCNScene(named: "cubeScene.scn")?.rootNode
    fileprivate let mono = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
    
    override var audioIsPlaying: Bool {
        didSet {
            self.isHidden = !audioIsPlaying
            
            if audioIsPlaying {
                self.audioPlayer.scheduleBuffer(self.audioBuffer, at: nil, options: .loops, completionHandler: nil)
                self.audioPlayer.play()
            } else {
                self.audioPlayer.stop()
            }
        }
    }
    
    override var position: SCNVector3 {
        willSet {
            self.audioPlayer.position = AVAudio3DPoint(x: newValue.x, y: newValue.y, z: newValue.z)
        }
    }
    
    
    init(atPosition position: SCNVector3, withAudioFile audioFilename: String, geometryName: String, geometryScaling: SCNVector3 = SCNVector3(1, 1, 1), eulerRotation: SCNVector3 = SCNVector3(0, 0, 0)) {
        
        super.init()
        // sceneKit bits
        guard let loadedGeometry = self.sceneWithCubeRoot?.childNode(withName: geometryName, recursively: true)?.geometry
            else { print("Fell down at the first hurdle"); return }
        
        self.geometry = loadedGeometry
        self.scale = geometryScaling
        self.position = position
        self.eulerAngles = eulerRotation
        
        // audio bits
        self.audioPlayer.renderingAlgorithm = .HRTFHQ
        self.audioPlayer.position = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)
        
        self.loadAudioFile(fromFile: audioFilename)
    }
    
    
    func loadAudioFile(fromFile filename: String) {
        
        // parsing of string
        guard let dotIndex = filename.firstIndex(of: ".")
            else { print("Error: Audio file not found"); return }
        let name = String(filename[...filename.index(before: dotIndex)])
        let type = String(filename[filename.index(after: dotIndex)...])
        
        // retrieval of full audio URL (filepath to main bundle)
        guard let fullFilePath = Bundle.main.path(forResource: name, ofType: type)
            else { print("Error: Audio file not found"); return }
        
        let audioURL = URL(fileURLWithPath: fullFilePath)
        
        // loading audio file
        guard let audioPlayerFile = try? AVAudioFile(forReading: audioURL)
            else { print("Error opening audio file"); return }
        
        // set up audio buffer (for loop playback capability)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: mono, frameCapacity: UInt32(audioPlayerFile.length)) else { print("PCM buffer set-up error"); return }
        buffer.frameLength = UInt32(audioPlayerFile.length)
        
        do {
            try audioPlayerFile.read(into: buffer)
        } catch {
            print("Buffer read failed")
        }
        
        self.audioBuffer = buffer
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

