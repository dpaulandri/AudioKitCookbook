import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

struct AutoWahData {
    var balance: AUValue = 0.5
}

class AutoWahConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let autowah: AutoWah
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        autowah = AutoWah(player)
        dryWetMixer = DryWetMixer(player, autowah)

        engine.output = dryWetMixer
    }

    @Published var data = AutoWahData() {
        didSet {
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        do { try engine.start() } catch let err { Log(err) }
    }

    func stop() {
        engine.stop()
    }
}

struct AutoWahView: View {
    @StateObject var conductor = AutoWahConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack(spacing: 50) {
                ForEach(conductor.autowah.parameters) {
                    ParameterEditor2(param: $0)
                }
                ParameterEditor2(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.autowah,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Auto Wah")
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct AutoWah_Previews: PreviewProvider {
    static var previews: some View {
        AutoWahView()
    }
}