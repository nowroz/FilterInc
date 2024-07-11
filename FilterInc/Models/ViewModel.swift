//
//  ViewModel.swift
//  FilterInc
//
//  Created by Nowroz Islam on 12/7/24.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation
import PhotosUI
import SwiftUI

@Observable final class ViewModel {
    var processedImage: Image?
    var photosPickerItem: PhotosPickerItem?
    var intensity: Double = 0.5
    var radius: Double = 100
    var scale: Double = 5
    var sharpness: Double = 0.5
    var currentFilter: CIFilter = .sepiaTone()
    var showingConfirmationDialog: Bool = false
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
    
    func loadImage() {
        Task { @MainActor in
            MainActor.assertIsolated("loadImage not isolated!")
            guard let photosPickerItem else { return }
            guard let imageData = try? await photosPickerItem.loadTransferable(type: Data.self) else {
                fatalError("Failed to load image data")
            }
            
            let ciImage = CIImage(data: imageData)
            
            guard let ciImage else {
                fatalError("Failed to initialize CIImage from image data")
            }
            
            currentFilter.setValue(ciImage, forKey: kCIInputImageKey)
            
            applyProcessing()
        }
    }
    
    func applyProcessing() {
        guard photosPickerItem != nil else { return }
        
        if currentFilter.inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(intensity, forKey: kCIInputIntensityKey)
        }
        if currentFilter.inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(scale, forKey: kCIInputScaleKey)
        }
        if currentFilter.inputKeys.contains(kCIInputSharpnessKey) {
            currentFilter.setValue(sharpness, forKey: kCIInputSharpnessKey)
        }
        if currentFilter.inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(radius, forKey: kCIInputRadiusKey)
        }

        guard let outputImage = currentFilter.outputImage else {
            fatalError()
        }
        
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            fatalError("Failed to create CGImage from CIImage")
        }
        
        let uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage)
    }
}

extension ViewModel {
    var isDisabled: Bool {
        processedImage == nil ? true : false
    }
    
    func sliderIsDisabled(filterKey: String) -> Bool {
        if currentFilter.inputKeys.contains(filterKey) == false {
            true
        } else {
            false
        }
    }
}
