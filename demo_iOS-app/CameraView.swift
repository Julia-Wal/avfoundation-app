// xcode: set sdk=iOS

//
//  CameraView.swift
//  demo_iOS-app
//
//  Created by Duc Nguyen on 02.11.26.
//

import SwiftUI

struct CameraView: View {
    var body: some View {
        
        VStack{
            
            HStack{
                Text("Camera")
                    .background(Color.white)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.white)
            
            ZStack{
                Image("MES02220")
                    .resizable()
                    .scaledToFill()
                
                VStack {
                    
                    Spacer()
                    
                    Image(systemName: "camera")
                        .font(.system(size: 70))
                        .foregroundStyle(.white)
                    
                    Text("Bam Bam Cam.")
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
                .padding()
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            //.clipped()
        }
    }
}

#Preview {
    CameraView()
}

