import SwiftUI

struct ContentView: View {
    @StateObject private var bleManager = BLEManager()
    
    var body: some View {
        NavigationStack{
            VStack {
                Text("Maglev Train Controller")
                    .font(.largeTitle)
                    .padding()
                
                if bleManager.foundPeripherals.isEmpty {
                    Text("No devices found")
                        .padding()
                } else {
                    List(bleManager.foundPeripherals, id: \.identifier) { peripheral in
                        if peripheral.name != nil{
                            Button(peripheral.name ?? "Unknown Device") {
                                bleManager.connectToDevice(peripheral)
                            }
                        }
                    }
                    .padding()
                    .frame(width: 500, height: 300)
                }
                
                if bleManager.isCharacteristicAvailable{
                    NavigationLink(destination: ControllerView(bleManager: bleManager)){
                        Text("Start controller")
                        .padding(7)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .cornerRadius(5)
                    }
                }else {
                    Text("Device not useable")
                }

                Text(bleManager.statusText)
            }
        }
    }
}

#Preview {
    ContentView()
}
