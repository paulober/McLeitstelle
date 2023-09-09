//
//  MarkerFilter.swift
//  McLeitstelle
//
//  Created by Paul on 06.09.23.
//

internal enum MarkerFilter: String, CaseIterable, Identifiable {
    case missions, buildings, all
    var id: Self { self }
}
