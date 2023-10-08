//
//  CodableBuilderFactory.swift
//
//
//  Created by Mikhail Maslo on 25.09.23.
//

protocol CodableBuilderFactory {
    func makeCodingKeysBuilder(buildingData: CodingKeysBuilder.BuildingData) -> CodeBuildable
    func makeDecoderBuilder(buildingData: DecodableBuilder.BuildingData) -> CodeBuildable
    func makeEncoderBuilder(buildingData: EncodableBuilder.BuildingData) -> CodeBuildable
}

final class DefaultCodableBuilderFactoryImpl: CodableBuilderFactory {
    func makeCodingKeysBuilder(buildingData: CodingKeysBuilder.BuildingData) -> CodeBuildable {
        CodingKeysBuilder(buildingData: buildingData)
    }

    func makeDecoderBuilder(buildingData: DecodableBuilder.BuildingData) -> CodeBuildable {
        DecodableBuilder(buildingData: buildingData)
    }

    func makeEncoderBuilder(buildingData: EncodableBuilder.BuildingData) -> CodeBuildable {
        EncodableBuilder(buildingData: buildingData)
    }
}
