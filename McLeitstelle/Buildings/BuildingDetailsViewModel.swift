//
//  BuildingDetailsViewModel.swift
//  McLeitstelle
//
//  Created by Paul on 04.09.23.
//

import Foundation
import LssKit
import Combine

@MainActor
internal class BuildingDetailsViewModel: ObservableObject {
    @Published var vehicles: [LssVehicle] = []
    private var cancellables = Set<AnyCancellable>()
    
    func fetchBuildingVehicles(for buildingId: Int) {
        fetchData(LssEndpoint.urlForV2BuildingsVehiclesByID(String(buildingId)), responseType: LssVehiclesResponseData.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Finished")
                    break
                case .failure(let error):
                    // Handle the error
                    print("Error: \(error)")
                }
            }, receiveValue: { responseObject in
                // Handle the responseObject of type [LssVehicle]
                self.vehicles = responseObject.result
            })
            .store(in: &cancellables)
    }
    
    func cleanUp() {
        cancellables.forEach { $0.cancel() }
    }
}
