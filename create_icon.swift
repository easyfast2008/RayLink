#!/usr/bin/swift

import Foundation
import CoreGraphics
import UniformTypeIdentifiers

// Create a simple gradient app icon
func createAppIcon(size: Int, path: String) {
    let width = size
    let height = size
    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * width
    let bitsPerComponent = 8
    
    var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
    
    // Create aurora gradient
    for y in 0..<height {
        for x in 0..<width {
            let offset = (y * width + x) * bytesPerPixel
            
            // Create gradient from purple to blue
            let progress = Double(y) / Double(height)
            let r = UInt8(128 * (1 - progress) + 64 * progress)
            let g = UInt8(64 * (1 - progress) + 128 * progress)
            let b = UInt8(255 * (1 - progress) + 255 * progress)
            
            pixelData[offset] = r     // R
            pixelData[offset + 1] = g // G
            pixelData[offset + 2] = b // B
            pixelData[offset + 3] = 255 // A
        }
    }
    
    // Add "R" letter in center
    let centerX = width / 2
    let centerY = height / 2
    let letterSize = width / 3
    
    for y in (centerY - letterSize/2)..<(centerY + letterSize/2) {
        for x in (centerX - letterSize/3)..<(centerX + letterSize/3) {
            let offset = (y * width + x) * bytesPerPixel
            
            // Simple "R" shape
            let relX = x - (centerX - letterSize/3)
            let relY = y - (centerY - letterSize/2)
            
            var isLetter = false
            
            // Vertical line of R
            if relX < letterSize/8 {
                isLetter = true
            }
            // Top curve of R
            if relY < letterSize/3 && relX < letterSize*2/3 {
                if abs(relX - letterSize/3) < letterSize/6 && relY < letterSize/4 {
                    isLetter = true
                }
            }
            // Diagonal of R
            if relY > letterSize/3 && relX > letterSize/4 {
                if abs(relY - letterSize/2) < letterSize/8 {
                    isLetter = true
                }
            }
            
            if isLetter {
                pixelData[offset] = 255     // R
                pixelData[offset + 1] = 255 // G
                pixelData[offset + 2] = 255 // B
                pixelData[offset + 3] = 255 // A
            }
        }
    }
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    
    guard let context = CGContext(data: &pixelData,
                                   width: width,
                                   height: height,
                                   bitsPerComponent: bitsPerComponent,
                                   bytesPerRow: bytesPerRow,
                                   space: colorSpace,
                                   bitmapInfo: bitmapInfo.rawValue) else {
        print("Failed to create context")
        return
    }
    
    guard let cgImage = context.makeImage() else {
        print("Failed to create image")
        return
    }
    
    // Save as PNG
    let url = URL(fileURLWithPath: path)
    guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        print("Failed to create destination")
        return
    }
    
    CGImageDestinationAddImage(destination, cgImage, nil)
    CGImageDestinationFinalize(destination)
    
    print("✅ Created icon: \(path)")
}

// Create 1024x1024 app icon
let iconPath = "/Users/alisimacpro/Desktop/RayLink/RayLink/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
createAppIcon(size: 1024, path: iconPath)