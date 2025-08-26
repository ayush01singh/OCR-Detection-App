// ChequeScannerScreen.swift
// SwiftUI screen for scanning cheques

import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject private var viewModel = ChequeScannerViewModel()
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Scan Your Cheque")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 32)
            ZStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 240)
                        .cornerRadius(16)
                        .shadow(radius: 8)
                        .padding(.horizontal)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 240)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "doc.text.viewfinder")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 48, height: 48)
                                    .foregroundColor(.accentColor)
                                Text("No cheque image selected")
                                    .foregroundColor(.secondary)
                                    .font(.body)
                            }
                        )
                        .padding(.horizontal)
                }
            }
            HStack(spacing: 20) {
                Button(action: { showCamera = true }) {
                    Label("Scan with Camera", systemImage: "camera.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("scan_with_camera_button")
                Button(action: { showImagePicker = true }) {
                    Label("Select from Photos", systemImage: "photo.on.rectangle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("select_from_photos_button")
            }
            .padding(.horizontal)
            if let cheque = viewModel.scannedCheque, let result = viewModel.validationResult {
                ChequeDetailsView(cheque: cheque, validationResult: result)
                    .padding(.top, 12)
            }
            Spacer()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker(image: $selectedImage)
        }
        .onChange(of: selectedImage) { newImage in
            if let image = newImage {
                viewModel.processChequeImage(image)
            }
        }
        .accessibilityIdentifier("cheque_scanner_screen")
    }
}

// MARK: - ImagePicker Wrapper
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.image = image as? UIImage
                }
            }
        }
    }
}

// MARK: - CameraPicker
import UIKit
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
