//
//  Utilities.swift
//  AudioPlacement
//
//  Created by Majid Alturki on 7/10/19.
//  Copyright © 2019 Majid Alturki. All rights reserved.
//

import Foundation
import ARKit

// MARK: - Collection extensions

extension Array where Iterator.Element == float3 {
    var average: float3? {
        guard !self.isEmpty else {
            return nil
        }
        
        let sum = self.reduce(float3(0)) { current, next in
            return current + next
        }
        return sum / Float(self.count)
    }
}

extension RangeReplaceableCollection {
    mutating func keepLast(_ elementsToKeep: Int) {
        if count > elementsToKeep {
            self.removeFirst(count - elementsToKeep)
        }
    }
}

// MARK: - float4x4 extensions

extension float4x4 {
    // Treats matrix as a (right-hand column-major convention) transform matrix
    // and factors out the translation component of the transform.
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
