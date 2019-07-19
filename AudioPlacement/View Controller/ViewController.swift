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
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var hitButton: UIButton!
    @IBOutlet weak var drawer: UIVisualEffectView!
    @IBOutlet weak var crosshairButton: UIButton!
    
    let icons = ["🎵", "🌦", "✉️"]
    var selectedIcon = "🎵"
    
    var audioSource: SCNAudioSource!
    
    // preview of the object that will be added
    //var previewNode: PreviewNode?
    
    // contains the object that will be placed
    var objectNode: SCNNode!

    
    /// The center of the screen, used for determining the location of the preview and (placed) object nodes
    var center: CGPoint!
    
    var positions = [SCNVector3]()
    
    // i dont need this because crosshairButton will always be in the middle of the screen anyways
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let hitTest = sceneView.hitTest(center, types: .featurePoint)
        let result = hitTest.last
        guard let transform = result?.worldTransform else {return}
        let thirdColumn = transform.columns.3
        let position = SCNVector3Make(thirdColumn.x, thirdColumn.y, thirdColumn.z)
        positions.append(position)
        let lastTenPositions = positions.suffix(10)
        SCNBox.position = getAveragePosition(from: lastTenPositions)
    }
    
    // This is helping function to get the average in SCNVector3 values
    func getAveragePosition(from positions : ArraySlice<SCNVector3>) -> SCNVector3 { // we're returning this because we want the average in SCNVector3
        var averageX : Float = 0
        var averageY : Float = 0
        var averageZ : Float = 0
        
        for position in positions {
            averageX += position.x
            averageY += position.y
            averageZ += position.z
        }
        let count = Float(positions.count)
        return SCNVector3Make(averageX / count , averageY / count, averageZ / count)
    }
    
    
    var isFirstPoint = true
    var points = [SCNNode]() // var to save all the points in nodes
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        
        let sphereGeometry = SCNSphere(radius: 0.005)
        let sphereNode = SCNNode(geometry: sphereGeometry)
        sphereNode.position = arrow.position //this should make sure there  object as to keep it in position
        sceneView.scene.rootNode.addChildNode(sphereNode)
        // when we add a child node to the sphere, we'll add it to points array
        points.append(sphereNode)
        
        if isFirstPoint {
            isFirstPoint = false
        } else {
            //calculate the distance
            let pointA = points[points.count - 2]
            guard let pointB = points.last else {return}
            
            let d = distance(float3(pointA.position), float3(pointB.position)) // casting to float3 from SCNVector3
            
            // add line
            let line = SCNGeometry.line(from: pointA.position, to: pointB.position)
            print(d.description)
            let lineNode = SCNNode(geometry: line)
            sceneView.scene.rootNode.addChildNode(lineNode)
            
            isFirstPoint = true
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sceneView.automaticallyUpdatesLighting = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        sceneView.delegate = self
        //objectNode = SCNNode()
        
        setUpAudio()

//        setUpCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        let configuration = ARWorldTrackingConfiguration()
        //configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        // Calculate `screenCenter` based on the current device orientation.
        center = CGPoint( x: view.bounds.midX, y: view.bounds.midY )
    }
    
    var isDrawerOpen = true
    
    @IBAction func hitTapped(_ sender: UIButton) {
        if isDrawerOpen {
            closeDrawer()
        } else {
            openDrawer()
        }
        
    }
    
    func openDrawer() {
        isDrawerOpen = true
        UIView.animate(withDuration: 0.3) {
            self.drawer.transform = CGAffineTransform.identity
        }
    }
    
    func closeDrawer() {
        isDrawerOpen = false
        UIView.animate(withDuration: 0.03) {
            self.drawer.transform = CGAffineTransform(translationX: 0, y: 100)
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        
        // stop the audio
        //objectNode.removeAllAudioPlayers()
        
        sceneView.session.pause()
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // Update `screenCenter` since the orientation of the device changed.
        center = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // create a player from the source and add it to the objectNode
        objectNode.addAudioPlayer(SCNAudioPlayer(source: audioSource))
        
        // place an object node on top of the plane's node
        node.addChildNode(objectNode)
        
        // disable plane detection after the model has been added
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [])
        
        // play a positional environment sound layer from the newly placed object
        playSound()
        
    }
    
    private func setUpAudio(){
        // instantiate an audio source
        audioSource = SCNAudioSource(fileNamed: "majorlazermono.mp3")
        
        // as an environmental sound layer the audio will play indefinitely
        audioSource.loops = true
        audioSource.isPositional = true
        audioSource.shouldStream = false

        // decode the audio from disk ahead of time
        audioSource.load()
    }
    
    private func playSound() {
        
        // ensure there is only one audio player
        objectNode.removeAllAudioPlayers()
        
        // create a player from the source and add it to the objectNode
        objectNode.addAudioPlayer(SCNAudioPlayer(source: audioSource))
    }
    
    
    
    
}
    
//    @IBOutlet var sceneView: ARSCNView!
//    @IBOutlet weak var ARInfoView: UIView!
//    @IBOutlet weak var objectSelectionView: UIView!
//
//    @IBOutlet weak var objectSelectionButton: UIButton!
//    @IBOutlet weak var objectSpawnPointCrosshairs: UIButton!
//
//    @IBOutlet weak var userInstructionLabel: UILabel!
//    @IBOutlet weak var ARBigLabel: UILabel!
//
//   // @IBOutlet weak var messageImage: UIImageView!
//    //@IBOutlet weak var weatherImage: UIImageView!
//    @IBOutlet weak var speakerImage: UIImageView!
//
//    // AVAudio communicates with low-level fs
//
//    let audioSession = AVAudioSession()
//    let sampleFreq = 44100.0
//    let bufferSize = 64
//
//    // Istantiate audio engine, device input, and input format
//    let audioEngine = AVAudioEngine()
//    var deviceInput: AVAudioInputNode!
//    var deviceInputFormat: AVAudioFormat!
//
//    // Instantiate a 3D audio envrionment node, this controls the position and rotation of how the user experiences AR sound
//    let audioEnvironment = AVAudioEnvironmentNode()
//    var mainMixer: AVAudioMixerNode!
//
//    let mono = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)
//    let stereo = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)
//
//    let lightSource = SCNLight()
//    let lightNode = SCNNode()
//
//    var sceneRootNode: SCNNode!
//
//    var binauralNodes = [ARAudioNode]()
//
//    let deviceInputDummy = AVAudioMixerNode()
//
//    //let barrierNode = ARAcousticBarrier(atPosition: SCNVector3(-0.5, 0, 0))
//
//
//
//
//    //
//    var planes = [UUID: VirtualPlane]() {
//        didSet {
//            if planes.count > 0 {
//                self.sessionStatus = .ready
//            } else {
//                if self.sessionStatus == .ready { self.sessionStatus = .initialised }
//            }
//        }
//    }
////
//    var sessionStatus = ARSessionState.initialised {
//        didSet {
//            DispatchQueue.main.async { self.userInstructionLabel.text = self.sessionStatus.description }
//            if sessionStatus == .failed { cleanupARSession() }
//            if sessionStatus == .temporarilyUnavailable {
//                DispatchQueue.main.async { self.ARBigLabel.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1) } }
//            if sessionStatus == .ready {
//                DispatchQueue.main.async { self.ARBigLabel.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1) } }
//        }
//    }
//
//
//
//
//    var objectImageViews = [UIImageView]()
//    let blackObjectImages = [UIImage(named: "speaker_black.png")]
//    //,
////                             UIImage(named: "weather_black.png"),
////                             UIImage(named: "whatsapp_black.png")]
//    let greyObjectImages = [UIImage(named: "speaker_grey.png")]
//
////        ,
////                            UIImage(named: "weather_grey.png"),
////                            UIImage(named: "whatsapp_grey.png")]
////
//    var objectSpawnPoint: CGPoint!
//
//
//    // Functions
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.objectImageViews = [self.speakerImage]
////            , self.weatherImage, self.messageImage]
//        self.objectSpawnPoint = CGPoint(x: self.objectSpawnPointCrosshairs.frame.midX, y: self.objectSpawnPointCrosshairs.frame.midY) //self.objectSpawnPointCrosshairs.frame.origin
//        self.objectSpawnPointCrosshairs.isHidden = true
//
//
//        // Audio Control
//
//        self.deviceInput = self.audioEngine.inputNode
//        self.deviceInputFormat = self.deviceInput.inputFormat(forBus: 0)
//        self.mainMixer = self.audioEngine.mainMixerNode
//        self.objectSelectionView.isHidden = true
//
//        // activate audio session (low-level)
//        self.activateAudioSession()
//
//        self.sceneRootNode = sceneView.scene.rootNode
//
//        // do routing of audio nodes (like patching a mixer)
//        self.audioRoutingSetup()
//
//        // starts our instance of AVAudioEngine (higher-level)
//        self.startAudioEngine()
//
//
//        // AR
//
//        // setup audio for speaker
//
//        // check here ARBinauralAudioSource
//
//        let speakerNode = ARBinauralAudioSource(atPosition: SCNVector3(0, 0, 0.5), withAudioFile: "majorlazermono.mp3", geometryName: "speaker", geometryScaling: SCNVector3(0.2, 0.2, 0.2))
//
//
//        self.binauralNodes.append(speakerNode) // 0
//
//        self.sceneRootNode.addChildNode(speakerNode)
//
//        self.audioEngine.attach(speakerNode.audioPlayer)
//
//        self.audioEngine.connect(speakerNode.audioPlayer, to: self.audioEnvironment, format: mono)
//
//        // hide the node
//        speakerNode.audioIsPlaying = false
//
//        // set initial images for object selection view
//        for (i, image) in self.objectImageViews.enumerated() {
//            image.image = self.blackObjectImages[i]
//        }
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        // use world tracking configuration (6DOF)
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = .horizontal
//
//        self.sceneView.delegate = self
//        // start AR processing session
//        self.sceneView.session.run(configuration)
//
//        // resume sessionStatus
//        // if self.planes.count > 0 { self.sessionStatus = .ready }
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        // pause session if view is going to go
//        self.sceneView.session.pause()
//
//        self.sessionStatus = .temporarilyUnavailable
//    }
//
//    @IBAction func panAction(_ sender: UIPanGestureRecognizer) {
//
//        let touchPoint = sender.location(in: self.sceneView)
//        let hitTestResults = self.sceneView.hitTest(touchPoint)
//
//        guard let selectedNode = hitTestResults.first?.node as? ARAudioNode else { return }
//
//        let zConstant = self.sceneView.projectPoint(selectedNode.position).z
//        selectedNode.position = self.sceneView.unprojectPoint(SCNVector3(Float(touchPoint.x),
//                                                                         Float(touchPoint.y),
//                                                                         zConstant))
//
//    }
//
//
//    @IBAction func objectSelectionButtonPressed(_ sender: UIButton) {
//
//        self.objectSelectionView.isHidden = !self.objectSelectionView.isHidden
//
//        self.objectSpawnPointCrosshairs.isHidden = !self.objectSpawnPointCrosshairs.isHidden
//
//        if self.objectSelectionView.isHidden {
//            self.objectSelectionButton.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
//        } else {
//            self.objectSelectionButton.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
//        }
//
//    }
//
//    func cleanupARSession() {
//        // enumerateChildNodes iterates through all the present child nodes and executes the code in the closure
//        self.sceneView.scene.rootNode.enumerateChildNodes{ (node, stop) -> Void in
//            node.removeFromParentNode()
//        }
//    }
//
//    @IBAction func imageButtonPressed(_ sender: UIButton) {
//
//        let selectedImageView = self.objectImageViews[sender.tag]
//        let selectedNode = self.binauralNodes[sender.tag]
//        let blackImageVersion = self.blackObjectImages[sender.tag]
//        let greyImageVersion = self.greyObjectImages[sender.tag]
//
//        if selectedNode.audioIsPlaying {
//            selectedNode.audioIsPlaying = false // also hides object
//
//            selectedImageView.image = blackImageVersion
//
//        } else {
//            let hitTestResults = self.sceneView.hitTest(self.objectSpawnPoint, types: .existingPlane)
//            guard hitTestResults.count > 0, let pointOnPlane = hitTestResults.first else { return }
//
//            let newObjectPosition = SCNVector3(pointOnPlane.worldTransform.columns.3.x,
//                                               pointOnPlane.worldTransform.columns.3.y,
//                                               pointOnPlane.worldTransform.columns.3.z)
//
//            selectedNode.position = newObjectPosition
//            selectedNode.audioIsPlaying = true // also makes object visible
//
//            selectedImageView.image = greyImageVersion
//            }
//        }
//}
    
    
    
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
    
    

