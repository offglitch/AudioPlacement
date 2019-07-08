//
//  VirtualPlane.swift
//  AudioPlacement
//
//  Created by Majid Alturki on 7/8/19.
//  Copyright © 2019 Majid Alturki. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

// this will be a type of SCNNode
class VirtualPlane: SCNNode {
    // implicitly unwrapped optional types!
    var anchor: ARAnchor!
    var planeGeometry: SCNPlane!
    
    init(anchor: ARPlaneAnchor) {
        super.init()
        
        self.anchor = anchor
        // the extent property gives us the area of the detected plane
        self.planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        // z and y inverted between ARKit and SceneKit
        
        let material = initialisePlaneMaterial()
        self.planeGeometry.materials = [material]
        
        self.geometry = planeGeometry
        // use z-coordinate
        self.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        // rotate SceneKit plane node 90 degrees (what a faff)
        self.transform = SCNMatrix4MakeRotation(-Float.pi/2.0, 1.0, 0.0, 0.0)
    }
    
    // just returns a plain white semi-transparent material - no options
    // would be fairly easy to add options - almost seems like a bit of a waste of a func to me
    func initialisePlaneMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white.withAlphaComponent(0) // completely transparent
        return material
    }
    
    func updateWithNewAnchor(_ anchor: ARPlaneAnchor) {
        // update position and  extent of plane
        planeGeometry.width = CGFloat(anchor.extent.x)
        planeGeometry.height = CGFloat(anchor.extent.z)
        position = SCNVector3(anchor.center.x, 0, anchor.center.z)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
