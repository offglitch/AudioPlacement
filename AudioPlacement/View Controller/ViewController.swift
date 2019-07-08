//
//  ViewController.swift
//  AudioPlacement
//
//  Created by Majid Alturki on 7/3/19.
//  Copyright © 2019 Majid Alturki. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var drone = SCNNode()
    var audioSource = SCNAudioSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        let scene = SCNScene(named: "art.scnassets/speaker.scn")!
        
        //load Drone
        drone = scene.rootNode.childNode(withName: "speaker", recursively: true)!
        
        // Load audioSource
        audioSource = SCNAudioSource(fileNamed: "art.scnassets/majorlazermono.mp3")!
        audioSource.loops = true
        audioSource.isPositional = true
        audioSource.shouldStream = false
        audioSource.load()
        sceneView.scene = scene
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        drone.removeAllAudioPlayers()
        drone.addAudioPlayer(SCNAudioPlayer(source: audioSource))
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    
}
