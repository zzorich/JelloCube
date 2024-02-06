//
//  JelloViewController.swift
//  ElasticJello
//
//  Created by lingji zhou on 2/4/24.
//

import Cocoa
import MetalKit

class JelloViewController: NSViewController {
    private let render = JelloRenderer()
    override func loadView() {
        view = MTKView(frame: .zero, device: render.device)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let view = self.view as! MTKView
        render.mtkView(view, drawableSizeWillChange: view.drawableSize)
        view.delegate = render
    }
    
}

#Preview {
    JelloViewController()
}
