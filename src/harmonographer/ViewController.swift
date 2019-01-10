//
//  ViewController.swift
//  harmonographer
//
//  Created by Connor yass on 1/6/19.
//  Copyright © 2019 HSY_Technologies. All rights reserved.
//

import Cocoa
import MetalKit

struct Vertex {
    var position: float3
    var color: float4
}

class ViewController: NSViewController {
    
    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var timer: CVDisplayLink!
    
    let verticies: [Vertex] = Array<Vertex>.init(repeating: Vertex(position: float3(-0.5, 0, 1.0), color: float4(1,0.0,0.4,1)), count: 10000)
    
    override func viewDidAppear() {
        super.viewDidLoad()
        
        device = MTLCreateSystemDefaultDevice()
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer!.frame
        view.layer?.addSublayer(metalLayer)
        
        let dataSize = verticies.count * MemoryLayout<Vertex>.size
        vertexBuffer = device.makeBuffer(bytes: verticies, length: dataSize, options: [])
        
        guard let defaultLibrary = device.makeDefaultLibrary() else {
            print("FATAL: device.makeDefaultLibrary() failed"); return;
        }
        guard let fragmentProgram = defaultLibrary.makeFunction(name: "fragment_shader") else {
            print("FATAL: Could not create fragment shader"); return;
        }
        guard let vertexProgram = defaultLibrary.makeFunction(name: "vertex_shader") else {
            print("FATAL: Could not create fragment shader"); return;
        }
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error as NSError {
            print(error);
        }
        
        commandQueue = device.makeCommandQueue()
        
        autoreleasepool {
            self.render()
        }
    }
    

    func render() {
        guard let drawable = metalLayer?.nextDrawable() else { return }
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0, blue: 0, alpha: 1.0)
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            print("FATAL: commandQueue.makeCommandBuffer() failed"); return;
        }
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            print("FATAL: commandBuffer.makeRenderCommandEncoder(...) failed"); return;
        }
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: verticies.count, instanceCount: 1)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

