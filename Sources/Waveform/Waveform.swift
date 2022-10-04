import AVFoundation
import MetalKit
import SwiftUI

#if os(macOS)
public struct Waveform: NSViewRepresentable {
    var samples: SampleBuffer
    var start: Int
    var length: Int
    var constants: Constants

    public init(samples: SampleBuffer, start: Int = 0, length: Int = 0, constants: Constants = Constants()) {
        self.samples = samples
        self.constants = constants
        self.start = start
        if length > 0 {
            self.length = min(length, samples.samples.count - start)
        } else {
            self.length = samples.samples.count - start
        }
    }

    public class Coordinator {
        var renderer: Renderer

        init(constants: Constants) {
            renderer = Renderer(device: MTLCreateSystemDefaultDevice()!)
        }
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(constants: constants)
    }

    public func makeNSView(context: Context) -> some NSView {
        let metalView = MTKView(frame: CGRect(x: 0, y: 0, width: 1024, height: 768),
                                device: MTLCreateSystemDefaultDevice()!)
        metalView.enableSetNeedsDisplay = true
        metalView.isPaused = true
        metalView.delegate = context.coordinator.renderer
        metalView.layer?.isOpaque = false
        return metalView
    }

    public func updateNSView(_ nsView: NSViewType, context: Context) {
        let renderer = context.coordinator.renderer
        renderer.constants = constants
        renderer.set(samples: samples,
                     start: start,
                     length: length)
        nsView.setNeedsDisplay(nsView.bounds)
    }
}
#else
public struct Waveform: UIViewRepresentable {
    var samples: SampleBuffer
    var start: Int
    var length: Int
    var constants: Constants

    public init(samples: SampleBuffer, start: Int = 0, length: Int = 0, constants: Constants = Constants()) {
        self.samples = samples
        self.constants = constants
        self.start = start
        if length > 0 {
            self.length = length
        } else {
            self.length = samples.samples.count
        }
    }

    public class Coordinator {
        var renderer: Renderer

        init(constants: Constants) {
            renderer = Renderer(device: MTLCreateSystemDefaultDevice()!)
        }
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(constants: constants)
    }

    public func makeUIView(context: Context) -> some UIView {
        let metalView = MTKView(frame: CGRect(x: 0, y: 0, width: 1024, height: 768),
                                device: MTLCreateSystemDefaultDevice()!)
        metalView.enableSetNeedsDisplay = true
        metalView.isPaused = true
        metalView.delegate = context.coordinator.renderer
        metalView.layer.isOpaque = false
        return metalView
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        let renderer = context.coordinator.renderer
        renderer.constants = constants
        renderer.set(samples: samples,
                     start: start,
                     length: length)
        uiView.setNeedsDisplay()
    }
}
#endif
