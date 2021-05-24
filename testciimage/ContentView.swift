//
//  ContentView.swift
//  testciimage
//
//  Created by 精廬幹人 on 2021/05/24.
//

import SwiftUI
import CoreImage
import CoreGraphics

func cocreateTestBuffer(colorSpace: CGColorSpace) -> CVPixelBuffer?{
    guard let pixelBuffer = { ()->CVPixelBuffer? in
              var pixeilBuffer:  CVPixelBuffer? = nil
              let (width,height) = (256,256)
              CVPixelBufferCreate( nil , width ,height,  kCVPixelFormatType_32BGRA ,
                                   [:] as CFDictionary , &pixeilBuffer )
              return pixeilBuffer
          }() else {
        return nil
    }
    do{
        CVPixelBufferLockBaseAddress( pixelBuffer , CVPixelBufferLockFlags( rawValue: 0 ))
        defer{
            CVPixelBufferUnlockBaseAddress( pixelBuffer , CVPixelBufferLockFlags( rawValue: 0 ))
        }
        if let pixel = CVPixelBufferGetBaseAddress( pixelBuffer )?.assumingMemoryBound(to: UInt8.self ){
            pixel[0] = 255 // B
            pixel[1] = 0   // G
            pixel[2] = 0   // R
            pixel[3] = 128 // A
        }
    }
    return pixelBuffer
}


struct ContentView: View {
    var body: some View {
        VStack{
            Text("Hello, world!")
            Button("button"){
                
                if let colorSpace = CGColorSpace(name: CGColorSpace.sRGB ){
                    print(colorSpace)
                    if let pixelBuffer = cocreateTestBuffer(colorSpace: colorSpace){
                        print(pixelBuffer)
                        
                        let context =
                            CIContext( options: [ CIContextOption.workingColorSpace:colorSpace,
                                                  CIContextOption.outputColorSpace:colorSpace,
                                                  CIContextOption.workingFormat: CIFormat.BGRA8 ,
                                                  // このオプション重要で出力時に、alpha値で ! 事前に乗算したピクセルデータを出力 ! する。
                                                  // デフォルトが true なのでオフにする
                                                  CIContextOption.outputPremultiplied: NSNumber(false) ])
                        print(context)
                        do {
                            let fileManager = FileManager.default
                            let docs = try fileManager.url(for: .documentDirectory,
                                                           in: .userDomainMask,
                                                           appropriateFor: nil, create: false)
                            let path = docs.appendingPathComponent("testdata.png")
                            try context.writePNGRepresentation(of: CIImage(cvPixelBuffer: pixelBuffer ,
                                                                           options: [.colorSpace: context.workingColorSpace as  Any] ),
                                                               to: path,
                                                               format: CIFormat.ARGB8,
                                                               colorSpace: colorSpace )
                            
                        } catch {
                            print(error)
                        }

                    }
                }else{
                    print("colorSpace failed")
                }
                print("Hello world")
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
