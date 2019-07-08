//
//  File.swift
//  AudioPlacement
//
//  Created by Majid Alturki on 7/8/19.
//  Copyright © 2019 Majid Alturki. All rights reserved.
//

import Foundation
import ARKit
import AVFoundation

class ARAudioNode: SCNNode {
    var audioIsPlaying = false
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
