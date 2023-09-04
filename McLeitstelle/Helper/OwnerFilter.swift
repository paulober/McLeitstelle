//
//  OwnerFilter.swift
//  McLeitstelle
//
//  Created by Paul on 03.09.23.
//

internal enum OwnerFilter: String, CaseIterable, Identifiable {
    case user, alliance, all
    var id: Self { self }
}
