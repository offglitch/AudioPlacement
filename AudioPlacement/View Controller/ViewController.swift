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
    @IBOutlet weak var objectSelectionView: UIView!
    
    @IBOutlet weak var objectSelectionButton: UIButton!
    @IBOutlet weak var objectSpawnPointCrosshairs: UIButton!
    
    @IBOutlet weak var userInstructionLabel: UILabel!
    
   // @IBOutlet weak var messageImage: UIImageView!
    //@IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var speakerImage: UIImageView!
    
    // AVAudio communicates with low-level fs
    
    let audioSession = AVAudioSession()
    let sampleFreq = 44100.0
    let bufferSize = 64
    
    // Istantiate audio engine, device input, and input format
    let audioEngine = AVAudioEngine()
    var deviceInput: AVAudioInputNode!
    var deviceInputFormat: AVAudioFormat!
    
    // Instantiate a 3D audio envrionment node, this controls the position and rotation of how the user experiences AR sound
    let audioEnvironment = AVAudioEnvironmentNode()
    var mainMixer: AVAudioMixerNode!
    
    let mono = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)
    let stereo = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)
    
    let lightSource = SCNLight()
    let lightNode = SCNNode()
    
    var sceneRootNode: SCNNode!
    
    var binauralNodes = [ARAudioNode]()
    
    
    //
    
    
    var objectImageViews = [UIImageView]()
    let blackObjectImages = [UIImage(named: "speaker_black.png")]
    //,
//                             UIImage(named: "weather_black.png"),
//                             UIImage(named: "whatsapp_black.png")]
    let greyObjectImages = [UIImage(named: "speaker_grey.png")]
        
//        ,
//                            UIImage(named: "weather_grey.png"),
//                            UIImage(named: "whatsapp_grey.png")]
//
    var objectSpawnPoint: CGPoint!
    
    
    // Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.objectImageViews = [self.speakerImage]
//            , self.weatherImage, self.messageImage]
        self.objectSpawnPoint = CGPoint(x: self.objectSpawnPointCrosshairs.frame.midX, y: self.objectSpawnPointCrosshairs.frame.midY) //self.objectSpawnPointCrosshairs.frame.origin
        self.objectSpawnPointCrosshairs.isHidden = true
        
        
        // Audio Control
        
        self.deviceInput = self.audioEngine.inputNode
        self.deviceInputFormat = self.deviceInput.inputFormat(forBus: 0)
        self.mainMixer = self.audioEngine.mainMixerNode
        self.objectSelectionView.isHidden = true
        
        // activate audio session (low-level)
        self.activateAudioSession()
        
        self.sceneRootNode = sceneView.scene.rootNode
        
        // do routing of audio nodes (like patching a mixer)
        self.audioRoutingSetup()
        
        // starts our instance of AVAudioEngine (higher-level)
        self.startAudioEngine()
        

        // AR
        
        // setup audio for speaker
        
        // check here ARBinauralAudioSource
        
        let speakerNode = ARBinauralAudioSource(atPosition: SCNVector3(0, 0, 0.5), withAudioFile: "majorlazermono.mp3", geometryName: "speaker", geometryScaling: SCNVector3(0.2, 0.2, 0.2))
        
        
        self.binauralNodes.append(speakerNode) // 0
        
        self.sceneRootNode.addChildNode(speakerNode)

        self.audioEngine.attach(speakerNode.audioPlayer)
        
        self.audioEngine.connect(speakerNode.audioPlayer, to: self.audioEnvironment, format: mono)
        
        // hide the node
        speakerNode.audioIsPlaying = false

        // set initial images for object selection view
        for (i, image) in self.objectImageViews.enumerated() {
            image.image = self.blackObjectImages[i]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // use world tracking configuration (6DOF)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal // I always forget this!
        
        self.sceneView.delegate = self
        // start AR processing session
        self.sceneView.session.run(configuration)
        
        // resume sessionStatus
        if self.planes.count > 0 { self.sessionStatus = .ready }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // pause session if view is going to go
        self.sceneView.session.pause()
        
        self.sessionStatus = .temporarilyUnavailable
    }
    
    @IBAction func panAction(_ sender: UIPanGestureRecognizer) {
        
        let touchPoint = sender.location(in: self.sceneView)
        let hitTestResults = self.sceneView.hitTest(touchPoint)
        
        guard let selectedNode = hitTestResults.first?.node as? ARAudioNode else { return }
        
        let zConstant = self.sceneView.projectPoint(selectedNode.position).z
        selectedNode.position = self.sceneView.unprojectPoint(SCNVector3(Float(touchPoint.x),
                                                                         Float(touchPoint.y),
                                                                         zConstant))
    }
    
    @IBAction func objectSelectionButtonPressed(_ sender: UIButton) {
        
        self.objectSelectionView.isHidden = !self.objectSelectionView.isHidden
        
        self.objectSpawnPointCrosshairs.isHidden = !self.objectSpawnPointCrosshairs.isHidden
        
        if self.objectSelectionView.isHidden {
            self.objectSelectionButton.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        } else {
            self.objectSelectionButton.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        }
        
    }
    
    func cleanupARSession() {
        // enumerateChildNodes iterates through all the present child nodes and executes the code in the closure
        self.sceneView.scene.rootNode.enumerateChildNodes{ (node, stop) -> Void in
            node.removeFromParentNode()
        }
    }
    
    
    @IBAction func imageButtonPressed(_ sender: Any) {
    }
    
}
    
    
    
//    var drone = SCNNode()
//    var audioSource = SCNAudioSource()
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        sceneView.delegate = self
//        let scene = SCNScene(named: "art.scnassets/speaker.scn")!
//
//        //load Drone
//        drone = scene.rootNode.childNode(withName: "speaker", recursively: true)!
//
//        // Load audioSource
//        audioSource = SCNAudioSource(fileNamed: "art.scnassets/majorlazermono.mp3")!
//        audioSource.loops = true
//        audioSource.isPositional = true
//        audioSource.shouldStream = false
//        audioSource.load()
//        sceneView.scene = scene
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        drone.removeAllAudioPlayers()
//        drone.addAudioPlayer(SCNAudioPlayer(source: audioSource))
//
//
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        let configuration = ARWorldTrackingConfiguration()
//        sceneView.session.run(configuration)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        sceneView.session.pause()
//    }
    
    

