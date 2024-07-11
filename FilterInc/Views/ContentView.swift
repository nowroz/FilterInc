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
    @State private var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                PhotosPicker(selection: $viewModel.photosPickerItem, matching: .images) {
                    Rectangle()
                        .stroke(.secondary, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                        .overlay {
                            if let processedImage = viewModel.processedImage {
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
                    Slider(value: $viewModel.intensity)
                        .disabled(viewModel.isDisabled || viewModel.sliderIsDisabled(filterKey: kCIInputIntensityKey))
                } label: {
                    Text("Intensity")
                        .foregroundStyle(viewModel.isDisabled || viewModel.sliderIsDisabled(filterKey: kCIInputIntensityKey) ? .gray : Color.primary)
                }
                
                LabeledContent {
                    Slider(value: $viewModel.radius, in: 1...200)
                        .disabled(viewModel.isDisabled || viewModel.sliderIsDisabled(filterKey: kCIInputRadiusKey))
                }label: {
                    Text("Radius")
                        .foregroundStyle(viewModel.isDisabled || viewModel.sliderIsDisabled(filterKey: kCIInputRadiusKey) ? .gray : Color.primary)
                }

                
                
                LabeledContent {
                    Slider(value: $viewModel.scale, in: 1...10)
                        .disabled(viewModel.isDisabled || viewModel.sliderIsDisabled(filterKey: kCIInputScaleKey))
                }label: {
                    Text("Scale")
                        .foregroundStyle(viewModel.isDisabled || viewModel.sliderIsDisabled(filterKey: kCIInputScaleKey) ? .gray : Color.primary)
                }

                
                
                LabeledContent {
                    Slider(value: $viewModel.sharpness)
                        .disabled(viewModel.isDisabled || viewModel.sliderIsDisabled(filterKey: kCIInputSharpnessKey))
                }label: {
                    Text("Sharpness")
                        .foregroundStyle(viewModel.isDisabled || viewModel.sliderIsDisabled(filterKey: kCIInputSharpnessKey) ? .gray : Color.primary)
                }

                

                HStack {
                    Button("Change Filter", systemImage: "camera.filters") {
                        viewModel.showingConfirmationDialog = true
                    }
                    .buttonStyle(.bordered)
                    .tint(.accentColor)
                    .disabled(viewModel.isDisabled)
                    
                    if let processedImage = viewModel.processedImage {
                        ShareLink("Share", item: processedImage, preview: SharePreview("FilterInc Image", image: processedImage))
                            .buttonStyle(.bordered)
                            .tint(.accentColor)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("FilterInc")
            .onChange(of: viewModel.photosPickerItem, viewModel.loadImage)
            .onChange(of: viewModel.intensity, viewModel.applyProcessing)
            .onChange(of: viewModel.radius, viewModel.applyProcessing)
            .onChange(of: viewModel.scale, viewModel.applyProcessing)
            .onChange(of: viewModel.sharpness, viewModel.applyProcessing)
            .confirmationDialog("Change Filter", isPresented: $viewModel.showingConfirmationDialog) {
                Button("Bloom") { viewModel.setFilter(.bloom())}
                Button("Color Invert") { viewModel.setFilter(.colorInvert()) }
                Button("Crystalize") { viewModel.setFilter(.crystallize()) }
                Button("Gloom") { viewModel.setFilter(.gloom()) }
                Button("Guassian Blur") { viewModel.setFilter(.gaussianBlur()) }
                Button("Pixellate") { viewModel.setFilter(.pixellate()) }
                Button("Sepia Tone") { viewModel.setFilter(.sepiaTone()) }
                Button("Sharpen Luminance") { viewModel.setFilter(.sharpenLuminance()) }
                Button("Vignette") { viewModel.setFilter(.vignette()) }
            }
        }
    }
}

#Preview {
    ContentView()
}
