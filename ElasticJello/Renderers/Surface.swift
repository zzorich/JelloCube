//
//  Surface.swift
//  ElasticJello
//
//  Created by lingji zhou on 2/5/24.
//

import Foundation
import simd

protocol Surface {
    func isCollied(objectPosition: SIMD3<Float>) -> Bool
    func colliedForce(at position: SIMD3<Float>, with velocity: SIMD3<Float>) -> SIMD3<Float>
    var kDamping: Float { get }
    var kElastic: Float { get }
}

struct BoundingBox: Surface {
    let minX: Float = -4
    let minY: Float = -4
    let minZ: Float = -4
    let maxX: Float = 4
    let maxY: Float = 4
    let maxZ: Float = 4

    let kDamping: Float
    let kElastic: Float

    func isCollied(objectPosition: SIMD3<Float>) -> Bool {
        objectPosition.x > maxX || objectPosition.x < minX ||
        objectPosition.x > maxY || objectPosition.y < minY ||
        objectPosition.x > maxZ || objectPosition.z < minZ
    }
    
    func colliedForce(at position: SIMD3<Float>, with velocity: SIMD3<Float>) -> SIMD3<Float> {
        var force = SIMD3<Float>(repeating: 0)
        if position.x < minX {
            let len = abs(position.x - minX)
            let relativeDir = SIMD3<Float>(-1, 0, 0);
            force += -kElastic * len * relativeDir;
            force += -kDamping * dot(relativeDir, velocity) * relativeDir;
        }

        if position.x > maxX {
            let len = abs(position.x - maxX)
            let relativeDir = SIMD3<Float>(1, 0, 0);
            force += -kElastic * len * relativeDir;
            force += -kDamping * dot(relativeDir, velocity) * relativeDir;
        }

        if position.y < minY {
            let len = abs(position.y - minY)
            let relativeDir = SIMD3<Float>(0, -1, 0);
            force += -kElastic * len * relativeDir;
            force += -kDamping * dot(relativeDir, velocity) * relativeDir;
        }

        if position.y > maxY {
            let len = abs(position.y - maxY);
            let relativeDir = SIMD3<Float>(0, 1, 0);
            force += -kElastic * len * relativeDir;
            force += -kDamping * dot(relativeDir, velocity) * relativeDir;
        }

        if position.z < minZ {
            let len = abs(position.z - minZ);
            let relativeDir = SIMD3<Float>(0, 0, -1);
            force += -kElastic * len * relativeDir;
            force += -kDamping * dot(relativeDir, velocity) * relativeDir;
        }


        if position.z > minZ {
            let len = abs(position.z - maxZ);
            let relativeDir = SIMD3<Float>(0, 0, 1);
            force += -kElastic * len * relativeDir;
            force += -kDamping * dot(relativeDir, velocity) * relativeDir;
        }
        return force;
    }
}

