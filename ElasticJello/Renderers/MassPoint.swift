//
//  MassPoint.swift
//  ElasticJello
//
//  Created by lingji zhou on 2/5/24.
//

import Foundation
import simd
typealias Vector3 = SIMD3<Float>

extension Vector3 {
    @inlinable var norm: Float { length(self) }
    @inlinable var unitVector: Self { return self / norm }
}

enum Intergrator {
    case RK4, Euler
}

class SpringMassCube {
    let intergrator: Intergrator = .RK4
    let dimension: Int = 0
    let externalForceField = DiscreteForceField_3D()
    let masses: [Float] = []
    var positions: [Vector3] = []
    var velocities: [Vector3] = []
    var accelarations: [Vector3] = []

    let dampingCoffecient: Float = 100
    let elasticsCoffecient: Float = 100

    typealias Index = (Int, Int, Int)

    @inlinable func flatIndexOf(index: Index) -> Int { index.0 * dimension * dimension + index.1 * dimension + index.2 }

    
}

extension SpringMassCube {
    private func isIndexValid(_ index: Index) -> Bool {
        let validRange = 0..<dimension
        return validRange.contains(index.0) && validRange.contains(index.1) && validRange.contains(index.2)
    }

    private func springNeighBoursOf(index: Index) -> [Index] {
        let (x, y, z) = index
        return [
            // Structral
            (x+2, y, z), (x-2, y, z),
            (x, y+2, z), (x, y-2, z),
            (x, y, z+2), (x, y, z-2),

            // Shear
            (x+1, y+1, z), (x-1, y-1, z), (x-1, y+1, z), (x+1, y-1, z),
            (x, y+1, z+1), (x, y-1, z-1), (x, y-1, z+1), (x, y+1, z-1),
            (x+1, y, z+1), (x+1, y, z-1), (x-1, y, z+1), (x+1, y, z-1),
            (x+1, y+1, z+1), (x-1, y-1, z-1),
            (x-1, y+1, z+1), (x+1, y-1, z+1), (x+1, y+1, z-1),
            (x-1, y-1, z+1), (x+1, y-1, z-1), (x-1, y+1, z-1),

            // Bending
            (x+1, y, z), (x-1, y, z),
            (x, y+1, z), (x, y-1, z),
            (x, y, z+1), (x, y, z-1),
        ].filter(isIndexValid)
    }
    
    func applySpringForces() {
        (0..<dimension * dimension * dimension).forEach { flatIndex in
            let index = (flatIndex / (dimension * dimension), flatIndex / dimension, flatIndex % dimension)

            for neighbour in springNeighBoursOf(index: index) {
                let restLength = Vector3(Float(neighbour.0 - index.0) / Float((dimension - 1)),
                                               Float(neighbour.1 - index.1) / Float((dimension - 1)),
                                               Float(neighbour.2 - index.2) / Float((dimension - 1))).norm
                let neighbourFlatIndex = flatIndexOf(index: neighbour)
                let relativePos = positions[flatIndex] - positions[neighbourFlatIndex]
                let relativeDirection = relativePos.unitVector
                let relativeSpeed = velocities[flatIndex] - velocities[neighbourFlatIndex]
                let springForce = -elasticsCoffecient * (relativePos.norm - restLength) * relativeDirection
                let dampingForce = -dampingCoffecient * dot(relativeSpeed, relativeDirection) * relativeDirection
                accelarations[flatIndex] += (springForce * dampingForce) / masses[flatIndex]
            }
        }
    }

    func applyExternalForces() {
        (0..<dimension * dimension * dimension).forEach { flatIndex in
            accelarations[flatIndex] += externalForceField.forceAt(position: positions[flatIndex])
        }
    }
}

struct DiscreteForceField_3D {
    let lowerBound = Vector3(-2.0, -2.0, -2.0)
    let upperBound = Vector3(-2.0, -2.0, -2.0)
    let resolution: Int = 0
    let forces: [Vector3] = []

    func forceAt(position: Vector3) -> Vector3 {
        let flatIndex: (Int, Int, Int) -> Int = { x, y, z in
            x * resolution * resolution + y * resolution + z
        }

        let invStep = Float(resolution) / (upperBound - lowerBound)
        let coordinate = invStep * (position - lowerBound)
        let zeroZeroCoord = clamp(floor(coordinate), min: 0, max: Float(resolution - 1))

        let diff = coordinate - zeroZeroCoord
        let alpha = diff.x
        let beta = diff.y
        let gamma = diff.z
        let x = Int(zeroZeroCoord.x)
        let y = Int(zeroZeroCoord.y)
        let z = Int(zeroZeroCoord.z)

        return (1.0 - alpha) * (1.0 - beta) * (1.0 - gamma) * forces[flatIndex(x, y, z)] +
                alpha * (1.0 - beta) * (1.0 - gamma) * forces[flatIndex(x+1, y, z)] +
                (1.0 - alpha) * beta * (1.0 - gamma) * forces[flatIndex(x, y+1, z)] +
                (1.0 - alpha) * (1.0 - beta) * gamma * forces[flatIndex(x, y, z+1)] +
                alpha * beta * (1.0 - gamma) * forces[flatIndex(x+1, y+1, z)] +
                alpha * (1.0 - beta) * gamma * forces[flatIndex(x+1, y, z+1)] +
                (1.0 - alpha) * beta * gamma * forces[flatIndex(x, y+1, z+1)] +
                alpha * beta * gamma * forces[flatIndex(x+1, y+1, z+1)]
    }
}
