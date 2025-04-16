//
//  RequestServiceViewModelProtocol.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 14..
//

import Foundation

@MainActor
final class RequestServiceViewModel: ObservableObject {
    @Published var description: String = ""
    @Published var selectedSeverity: String = ""
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var submissionSuccess: Bool = false
    
    let service: ServiceProfile
    let userAddress: Address
    private let serviceRequestService: ServiceRequestServiceProtocol
    
    var isFormValid: Bool {
        !description.isEmpty && !selectedSeverity.isEmpty
    }
    
    init(service: ServiceProfile,
         serviceRequestService: ServiceRequestServiceProtocol = ServiceRequestService()) {
        self.service = service
        self.serviceRequestService = serviceRequestService
        self.userAddress = AuthenticatedUser.shared.currentUser?.address ?? Address.defaultAddress()
    }
    
    func submitRequest() async {
        guard isFormValid else {
            showError(message: "Please fill all required fields")
            return
        }
        
        let addressDTO = AddressRequest(
            city: userAddress.city,
            country: userAddress.country,
            zipCode: userAddress.zipCode,
            addressLine: userAddress.addressLine
        )
        
        let requestDTO = ServiceRequestDTO(
            description: description,
            severity: ServiceRequestDTO.SeverityLevel(rawValue: selectedSeverity.uppercased()) ?? .MEDIUM,
            serviceId: service.id,
            address: addressDTO
        )
        
        do {
            _ = try await serviceRequestService.submitRequest(requestDTO)
            await MainActor.run {
                submissionSuccess = true
            }
        } catch let error as NetworkError {
            handleNetworkError(error)
        } catch {
            handleGenericError(error)
        }
    }
    
    private func handleNetworkError(_ error: NetworkError) {
        switch error {
        case .unauthorized:
            showError(message: "Session expired. Please login again.")
        case .serverError(let code):
            showError(message: "Server error (\(code)). Please try again later.")
        default:
            showError(message: error.errorDescription ?? "Network error occurred")
        }
    }
    
    private func handleGenericError(_ error: Error) {
        showError(message: error.localizedDescription)
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}
