//
//  DIContainer.swift
//  App
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation
import UIKit
import Networking
import MoviesSearch

final class AppDIContainer {
    
    lazy var appConfigurations = AppConfigurations()
    
    // MARK: - Network
    lazy var apiDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(baseURL: URL(string: appConfigurations.apiBaseURL)!,
                                          queryParameters: ["api_key": appConfigurations.apiKey,
                                                            "language": NSLocale.preferredLanguages.first ?? "en"])
        
        let apiDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: apiDataNetwork)
    }()
    lazy var imageDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(baseURL: URL(string: appConfigurations.imagesBaseURL)!)
        let imagesDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: imagesDataNetwork)
    }()
    
    // DIContainers of scenes
    func makeMoviesSearchDIContainer() -> MoviesSearch.DIContainer {
        let dependencies = MoviesSearch.DIContainer.Dependencies(apiDataTransferService: apiDataTransferService,
                                                                 imageDataTransferService: imageDataTransferService)
        return DIContainer(dependencies: dependencies)
    }
}
