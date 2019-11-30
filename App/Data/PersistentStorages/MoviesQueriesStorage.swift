//
//  MoviesQueriesStorage.swift
//  App
//
//  Created by Oleh Kudinov on 16.08.19.
//

import Foundation

protocol MoviesQueriesStorage {
    func recentsQueries(number: Int, completion: @escaping (Result<[MovieQuery], Error>) -> Void)
    func saveRecentQuery(query: MovieQuery, completion: @escaping (Result<MovieQuery, Error>) -> Void)
}
