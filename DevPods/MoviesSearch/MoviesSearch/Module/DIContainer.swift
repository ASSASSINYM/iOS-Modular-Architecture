//
//  DIContainer.swift
//  App
//
//  Created by Oleh Kudinov on 03.03.19.
//

import UIKit
import SwiftUI
import Networking

public final class DIContainer {
    
    public struct Dependencies {
        let apiDataTransferService: DataTransferService
        let imageDataTransferService: DataTransferService
        
        public init (apiDataTransferService: DataTransferService, imageDataTransferService: DataTransferService) {
            self.apiDataTransferService = apiDataTransferService
            self.imageDataTransferService = imageDataTransferService
        }
    }
    
    private let dependencies: Dependencies

    // MARK: - Persistent Storage
    lazy var moviesQueriesStorage: MoviesQueriesStorage = CoreDataStorage(maxStorageLimit: 10)
    
    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Use Cases
    func makeSearchMoviesUseCase() -> SearchMoviesUseCase {
        return DefaultSearchMoviesUseCase(moviesRepository: makeMoviesRepository(),
                                          moviesQueriesRepository: makeMoviesQueriesRepository())
    }
    
    func makeFetchRecentMovieQueriesUseCase() -> FetchRecentMovieQueriesUseCase {
        return DefaultFetchRecentMovieQueriesUseCase(moviesQueriesRepository: makeMoviesQueriesRepository())
    }
    
    // MARK: - Repositories
    func makeMoviesRepository() -> MoviesRepository {
        return DefaultMoviesRepository(dataTransferService: dependencies.apiDataTransferService)
    }
    func makeMoviesQueriesRepository() -> MoviesQueriesRepository {
        return DefaultMoviesQueriesRepository(dataTransferService: dependencies.apiDataTransferService,
                                              moviesQueriesPersistentStorage: moviesQueriesStorage)
    }
    func makePosterImagesRepository() -> PosterImagesRepository {
        
        return DefaultPosterImagesRepository(dataTransferService: dependencies.imageDataTransferService,
                                             imageNotFoundData: (#imageLiteral(resourceName: "image_not_found") as LiteralBundleImage).image?.pngData())
    }
    
    // MARK: - Movies List
    public func makeMoviesListViewController() -> UIViewController {
        return MoviesListViewController.create(with: makeMoviesListViewModel(), moviesListViewControllersFactory: self)
    }
    
    func makeMoviesListViewModel() -> MoviesListViewModel {
        return DefaultMoviesListViewModel(searchMoviesUseCase: makeSearchMoviesUseCase(),
                                          posterImagesRepository: makePosterImagesRepository())
    }
    
    // MARK: - Movie Details
    func makeMoviesDetailsViewController(title: String,
                                         overview: String,
                                         posterPlaceholderImage: Data?,
                                         posterPath: String?) -> UIViewController {
        return MovieDetailsViewController.create(with: makeMoviesDetailsViewModel(title: title,
                                                                                  overview: overview,
                                                                                  posterPlaceholderImage: posterPlaceholderImage,
                                                                                  posterPath: posterPath))
    }
    
    func makeMoviesDetailsViewModel(title: String,
                                    overview: String,
                                    posterPlaceholderImage: Data?,
                                    posterPath: String?) -> MovieDetailsViewModel {
        return DefaultMovieDetailsViewModel(title: title,
                                            overview: overview,
                                            posterPlaceholderImage: posterPlaceholderImage,
                                            posterPath: posterPath,
                                            posterImagesRepository: makePosterImagesRepository())
    }
    
    // MARK: - Movies Queries Suggestions List
    func makeMoviesQueriesSuggestionsListViewController(delegate: MoviesQueryListViewModelDelegate) -> UIViewController {
        if #available(iOS 13.0, *) { // SwiftUI
            let view = MoviesQueryListView(viewModelWrapper: makeMoviesQueryListViewModelWrapper(delegate: delegate))
            return UIHostingController(rootView: view)
        } else { // UIKit
            return MoviesQueriesTableViewController.create(with: makeMoviesQueryListViewModel(delegate: delegate))
        }
    }
    
    func makeMoviesQueryListViewModel(delegate: MoviesQueryListViewModelDelegate) -> MoviesQueryListViewModel {
        return DefaultMoviesQueryListViewModel(numberOfQueriesToShow: 10,
                                               fetchRecentMovieQueriesUseCase: makeFetchRecentMovieQueriesUseCase(),
                                               delegate: delegate)
    }

    @available(iOS 13.0, *)
    func makeMoviesQueryListViewModelWrapper(delegate: MoviesQueryListViewModelDelegate) -> MoviesQueryListViewModelWrapper {
        return MoviesQueryListViewModelWrapper(viewModel: makeMoviesQueryListViewModel(delegate: delegate))
    }
}

extension DIContainer: MoviesListViewControllersFactory {}
