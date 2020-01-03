//
//  Movie.swift
//  App
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

struct MoviesPage {
    let page: Int
    let totalPages: Int
    let movies: [Movie]
}

typealias MovieId = String

struct Movie {
    let id: MovieId
    let title: String
    let posterPath: String?
    let overview: String
    let releaseDate: Date?
}
