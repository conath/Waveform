import AVFoundation
import SwiftUI
import Waveform

class WaveformDemoModel: ObservableObject {
    var samples: SampleBuffer

    init(file: AVAudioFile) {
        let stereo = file.toFloatChannelData()!
        samples = SampleBuffer(samples: stereo[0])
    }
}

func getFile() -> AVAudioFile {
    let url = Bundle.main.url(forResource: "beat", withExtension: "aiff")!
    return try! AVAudioFile(forReading: url)
}

func clamp(_ x: Double, _ inf: Double, _ sup: Double) -> Double {
    max(min(x, sup), inf)
}

struct ContentView: View {

    @StateObject var model = WaveformDemoModel(file: getFile())

    @State var start = 0.0
    @GestureState var dragStart = 0.0
    @State var length = 1.0
    @GestureState var dragLength = 0.0

    let indicatorSize = 10.0
    
    var finalStart: Double {
        clamp(start + dragStart, 0, 1)
    }
    
    var finalLength: Double {
        length + dragLength
    }

    let formatter = NumberFormatter()
    var body: some View {
        VStack {

            GeometryReader { gp in
                ZStack(alignment: .leading) {
                    Waveform(samples: model.samples)
                    RoundedRectangle(cornerRadius: indicatorSize)
                        .frame(width: max(3 * indicatorSize, min(gp.size.width * finalLength,
                                                                 gp.size.width - finalStart * gp.size.width)))
                        .offset(x: min(gp.size.width - 3 * indicatorSize, finalStart) * gp.size.width)
                        .opacity(0.5)
                        .gesture(DragGesture()
                            .updating($dragStart) { drag, dragStart, _ in
                                dragStart = (drag.location.x - drag.startLocation.x) / gp.size.width
                            }
                            .onEnded { drag in
                                start += (drag.location.x - drag.startLocation.x) / gp.size.width
                                start = clamp(start, 0, 1)
                                length = min(length, 1 - start)
                            }
                                 
                        )
                    RoundedRectangle(cornerRadius: indicatorSize)
                        .foregroundColor(.black)
                        .frame(width: indicatorSize).opacity(0.3)
                        .offset(x: max(0, finalStart + finalLength) * gp.size.width - 3 * indicatorSize)
                        .padding(indicatorSize)
                        .gesture(DragGesture()
                            .updating($dragLength) { drag, dragLength, _ in
                                dragLength = (drag.location.x - drag.startLocation.x) / gp.size.width
                            }
                            .onEnded { drag in
                                length += (drag.location.x - drag.startLocation.x) / gp.size.width
                                if length < 0 {
                                    print("resetting length")
                                    length = 1
                                }
                            }
                                 
                        )
                    
                }
            }
            .frame(height: 100)
            Waveform(samples: model.samples,
                     start: Int(max(0, min(1,(start + dragStart))) * Double(model.samples.count - 1)),
                     length: Int(max(0, min(1, (length + dragLength))) * Double(model.samples.count)))
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
