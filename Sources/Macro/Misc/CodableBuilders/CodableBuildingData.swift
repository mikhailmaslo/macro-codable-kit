//
//  File.swift
//
//
//  Created by Mikhail Maslo on 07.10.23.
//

import Foundation

struct CodableBuildingData {
    let codingKeysBuildingData: CodingKeysBuilder.BuildingData?
    let encodingBuildingData: EncodableBuilder.BuildingData?
    let decodingBuildingData: DecodableBuilder.BuildingData?
}
