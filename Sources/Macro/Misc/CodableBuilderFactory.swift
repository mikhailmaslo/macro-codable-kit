//
//  CodableBuilderFactory.swift
//
//
//  Created by Mikhail Maslo on 25.09.23.
//

protocol CodableBuilderFactory {
    func makeDecoderBuilder(instance: Instance) -> any CodeBuildable
    func makeEncoderBuilder(instance: Instance) -> any CodeBuildable
}

final class DefaultCodableBuilderFactoryImpl: CodableBuilderFactory {
    private let strategy: CodableStrategy

    init(strategy: CodableStrategy) {
        self.strategy = strategy
    }

    func makeDecoderBuilder(instance: Instance) -> CodeBuildable {
        DefaultDecodableBuilder(
            accessModifier: instance.isPublic ? .public : nil,
            strategy: strategy,
            members: instance.members
        )
    }

    func makeEncoderBuilder(instance: Instance) -> CodeBuildable {
        DefaultEncodableBuilder(
            accessModifier: instance.isPublic ? .public : nil,
            strategy: strategy,
            members: instance.members
        )
    }
}
