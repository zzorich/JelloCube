//
//  MetalView.swift
//  ElasticJello
//
//  Created by lingji zhou on 2/4/24.
//

import SwiftUI
import MetalKit

struct MetalView: ViewRepresentable {
    let renderer: JelloRenderer
    func makeView(context: Context) -> MTKView {
        let view = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice()!)

        view.preferredFramesPerSecond = 30
        view.delegate = renderer
        view.colorPixelFormat = .bgra8Unorm

        return view
    }

    func updateView(_ view: MTKView, context: Context) {
        view.delegate = renderer
    }
    
}

#Preview {
    MetalView(renderer: JelloRenderer())
}
