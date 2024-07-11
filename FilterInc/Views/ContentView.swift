//
//  ContentView.swift
//  FilterInc
//
//  Created by Nowroz Islam on 10/7/24.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import SwiftUI

struct ContentView: View {
    @State private var processedImage: Image?
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var intensity: Double = 0.5
    @State private var radius: Double = 100
    @State private var scale: Double = 5
    @State private var sharpness: Double = 0.5
    @State private var currentFilter: CIFilter = .sepiaTone()
    @State private var showingConfirmationDialog: Bool = false
    
    var isDisabled: Bool {
        processedImage == nil ? true : false
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                PhotosPicker(selection: $photosPickerItem, matching: .images) {
                    Rectangle()
                        .stroke(.secondary, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                        .overlay {
                            if let processedImage {
                                processedImage
                                    .resizable()
                                    .scaledToFit()
                                    .padding()
                            } else {
                                ContentUnavailableView("No Photo", systemImage: "photo.badge.plus", description: Text("Tap to import a photo."))
                            }
                        }
                }
                .buttonStyle(.plain)
                
                Divider()
                
                LabeledContent {
                    Slider(value: $intensity)
                        .disabled(isDisabled || sliderIsDisabled(filterKey: kCIInputIntensityKey))
                } label: {
                    Text("Intensity")
                        .foregroundStyle(isDisabled || sliderIsDisabled(filterKey: kCIInputIntensityKey) ? .gray : Color.primary)
                }
                
                LabeledContent {
                    Slider(value: $radius, in: 1...200)
                        .disabled(isDisabled || sliderIsDisabled(filterKey: kCIInputRadiusKey))
                }label: {
                    Text("Radius")
                        .foregroundStyle(isDisabled || sliderIsDisabled(filterKey: kCIInputRadiusKey) ? .gray : Color.primary)
                }

                
                
                LabeledContent {
                    Slider(value: $scale, in: 1...10)
                        .disabled(isDisabled || sliderIsDisabled(filterKey: kCIInputScaleKey))
                }label: {
                    Text("Scale")
                        .foregroundStyle(isDisabled || sliderIsDisabled(filterKey: kCIInputScaleKey) ? .gray : Color.primary)
                }

                
                
                LabeledContent {
                    Slider(value: $sharpness)
                        .disabled(isDisabled || sliderIsDisabled(filterKey: kCIInputSharpnessKey))
                }label: {
                    Text("Sharpness")
                        .foregroundStyle(isDisabled || sliderIsDisabled(filterKey: kCIInputSharpnessKey) ? .gray : Color.primary)
                }

                

                HStack {
                    Button("Change Filter", systemImage: "camera.filters") {
                        showingConfirmationDialog = true
                    }
                    .buttonStyle(.bordered)
                    .tint(.accentColor)
                    .disabled(isDisabled)
                    
                    if let processedImage {
                        ShareLink("Share", item: processedImage, preview: SharePreview("FilterInc Image", image: processedImage))
                            .buttonStyle(.bordered)
                            .tint(.accentColor)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("FilterInc")
            .onChange(of: photosPickerItem, loadImage)
            .onChange(of: intensity, applyProcessing)
            .onChange(of: radius, applyProcessing)
            .onChange(of: scale, applyProcessing)
            .onChange(of: sharpness, applyProcessing)
            .confirmationDialog("Change Filter", isPresented: $showingConfirmationDialog) {
                Button("Bloom") { setFilter(.bloom())}
                Button("Color Invert") { setFilter(.colorInvert()) }
                Button("Crystalize") { setFilter(.crystallize()) }
                Button("Gloom") { setFilter(.gloom()) }
                Button("Guassian Blur") { setFilter(.gaussianBlur()) }
                Button("Pixellate") { setFilter(.pixellate()) }
                Button("Sepia Tone") { setFilter(.sepiaTone()) }
                Button("Sharpen Luminance") { setFilter(.sharpenLuminance()) }
                Button("Vignette") { setFilter(.vignette()) }
            }
        }
    }
    
    func sliderIsDisabled(filterKey: String) -> Bool {
        if currentFilter.inputKeys.contains(filterKey) {
            false
        } else {
            true
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
    
    func loadImage() {
        Task { @MainActor in
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

#Preview {
    ContentView()
}
