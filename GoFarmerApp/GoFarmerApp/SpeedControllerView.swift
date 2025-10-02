//
//  SpeedControllerView.swift
//  GoFarmerApp
//
//  Created by 徐來慶 on 2025/5/20.
//

import SwiftUI

struct SpeedControllerView: View {
    
    @State private var pos : CGFloat = 0
    var sliderHeight : CGFloat = (UIScreen.main.bounds.height)*0.7
    @State private var tapY : CGFloat = 0
    @Binding var speed : CGFloat
    
    var body: some View {
        
        VStack{
            ZStack{
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: 150, height: sliderHeight)
                    .cornerRadius(20)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged{value in
                                if value.location.y-sliderHeight/2 > (sliderHeight-90)/2{
                                    pos = (sliderHeight-90)/2
                                } else if value.location.y-sliderHeight/2 < -(sliderHeight-90)/2{
                                    pos = -(sliderHeight-90)/2
                                } else {
                                    pos = value.location.y-sliderHeight/2
                                }
                                speed = -CGFloat(2*pos/(sliderHeight-90))*1024
                        }
                            .onEnded{ _ in
                                withAnimation(.easeInOut(duration: 0.1)){
                                    pos = 0
                                    speed = 0
                                }
                            }
                    )
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 120, height: 50)
                    .cornerRadius(20)
                    .offset(x:0, y: pos)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if value.translation.height > (sliderHeight-90)/2{
                                    pos = (sliderHeight-90)/2
                                } else if value.translation.height < -(sliderHeight-90)/2{
                                    pos = -(sliderHeight-90)/2
                                } else {
                                    pos = value.translation.height
                                }
                                speed = -CGFloat(2*pos/(sliderHeight-90))*1024
                            }
                            .onEnded { value in
                                withAnimation(.easeInOut(duration: 0.1)){
                                    pos = 0
                                    speed = 0
                                }
                            }
                    )
            }

        }
    }
}

#Preview {
    SpeedControllerView(speed: .constant(0))
}
