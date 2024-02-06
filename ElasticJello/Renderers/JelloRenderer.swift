//
//  JelloRenderer.swift
//  ElasticJello
//
//  Created by lingji zhou on 2/4/24.
//

import Foundation
import MetalKit
import simd

private let vertices = [
    AAPLVertex(position: vector_float2(250, -250), color: vector_float4(1, 0, 0, 1)),
    AAPLVertex(position: vector_float2(-250, -250), color: vector_float4(0, 1, 0, 1)),
    AAPLVertex(position: vector_float2(0, 250), color: vector_float4(0, 0, 1, 1)),
]
final class JelloRenderer: NSObject, MTKViewDelegate, ObservableObject {
    public let device: MTLDevice

    private let commandQueue: MTLCommandQueue
    private let piplineState: MTLRenderPipelineState

    private var viewPortSize: vector_uint2 = vector_uint2()


    override init() {
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!

        let defaultLibrary = device.makeDefaultLibrary()!
        let vertexShader = defaultLibrary.makeFunction(name: "vertexShader")!
        let fragmentShader = defaultLibrary.makeFunction(name: "fragmentShader")!

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.label = "Simple Pipeline"
        pipelineStateDescriptor.vertexFunction = vertexShader
        pipelineStateDescriptor.fragmentFunction = fragmentShader
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        piplineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        super.init()
    }


    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewPortSize.x = UInt32(Float(size.width))
        viewPortSize.y = UInt32(Float(size.height))
    }

    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        defer { commandBuffer.commit() }
        commandBuffer.label = "Triangle Command"
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        renderEncoder.label = "TriangleRenderEncoder"
        renderEncoder.setViewport(MTLViewport(originX: 0, originY: 0, width: Double(viewPortSize.x), height: Double(viewPortSize.y), znear: 0, zfar: 1))

        renderEncoder.setRenderPipelineState(piplineState)
        renderEncoder.setVertexBytes(vertices, length: MemoryLayout<AAPLVertex>.size * vertices.count, index: Int(AAPLVertexInputIndexVertices.rawValue))
        renderEncoder.setVertexBytes(&viewPortSize, length: MemoryLayout.size(ofValue: viewPortSize), index: Int(AAPLVertexInputIndexViewportSize.rawValue))

        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        renderEncoder.endEncoding()
        if let drawable = view.currentDrawable { commandBuffer.present(drawable) }
    }
    

}
