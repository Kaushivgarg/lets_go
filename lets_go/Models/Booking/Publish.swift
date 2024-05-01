//
//  Publish.swift
//  lets_go
//
//  Created by Ishan Singla on 30/04/24.
//

import Foundation

struct Publish {
    var id: String
    var publisherUserId: String
    var publisher: User?
    var totalNoOfSeets: Int
    var noOfSeetsAvailable: Int
    var costPerSeet: Float
    var dateTime: Date
    var createdAt: Date
    var updatedAt: Date
    var bookings: [Booking]
}
