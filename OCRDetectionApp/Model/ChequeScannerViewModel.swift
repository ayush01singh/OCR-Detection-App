// ChequeScannerViewModel.swift
// ViewModel for cheque scanning and validation

import Foundation
import SwiftUI

final class ChequeScannerViewModel: ObservableObject {
    @Published var scannedCheque: Cheque?
    @Published var validationResult: ChequeValidationResult?
    @Published var isLoading: Bool = false
    
    private let ocrService: ChequeOCRServiceProtocol
    private let validationService: ChequeValidationServiceProtocol
    
    init(
        ocrService: ChequeOCRServiceProtocol = ChequeOCRService(),
        validationService: ChequeValidationServiceProtocol = ChequeValidationService()
    ) {
        self.ocrService = ocrService
        self.validationService = validationService
    }
    
    // MARK: - Process Cheque Image
    func processChequeImage(_ image: UIImage) {
        isLoading = true
        validationResult = nil
        scannedCheque = nil
        
        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            isLoading = false
            validationResult = ChequeValidationResult(status: .invalid(["Failed to process image data."]), validatedCheque: nil)
            return
        }
        
        ocrService.extractChequeData(from: imageData) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let cheque):
                    self.scannedCheque = cheque
                    self.validationResult = self.validationService.validate(cheque: cheque)
                case .failure(let error):
                    self.validationResult = ChequeValidationResult(status: .invalid([error.localizedDescription]), validatedCheque: nil)
                }
            }
        }
    }
}
