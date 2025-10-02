//
//  Controller.swift
//  GoFarmerApp
//
//  Created by 徐來慶 on 2025/5/16.
//
import SwiftUI

struct ControllerView: View {
    @StateObject var bleManager = BLEManager()
    @State var lSpeed : CGFloat = 0
    @State var rSpeed : CGFloat = 0
    @State var isLightLit : Bool = false
    
    func sendSpeed(){
        bleManager.sendData("\(Int(lSpeed)),\(Int(rSpeed))")
    }
    
    var body: some View {
        VStack{
            HStack{
                SpeedControllerView(speed: $lSpeed)
                Spacer()
                SpeedControllerView(speed: $rSpeed)
            }
            HStack{
                Text(String(Int(lSpeed)))
                Spacer()
                Text(String(Int(rSpeed)))
            }
            HStack{
                Label("", systemImage: "bell.and.waves.left.and.right.fill")
                    .onTapGesture {_ in
                        bleManager.sendData("H")
                    }
                Text(bleManager.statusText)
                if isLightLit{
                    Label("", systemImage: "lightbulb.slash")
                        .onTapGesture {_ in
                            bleManager.sendData("Y")
                            isLightLit.toggle()
                        }
                        .frame(width: 20, height: 20)
                } else {
                    Label("", systemImage: "lightbulb.fill")
                        .onTapGesture {_ in
                            bleManager.sendData("K")
                            isLightLit.toggle()
                    }
                        .frame(width: 20, height: 20)
                }
            }
        }
        .padding(50)
        .onChange(of: lSpeed) { _ in
            sendSpeed()
        }
        .onChange(of: rSpeed) { _ in
            sendSpeed()
        }
    }
}

#Preview {
    ControllerView()
}
