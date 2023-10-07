//
//  AllOfMacroTests.swift
//
//
//  Created by Mikhail Maslo on 23.09.23.
//

#if canImport(Macro)
    import Macro
    import MacroTesting
    import SwiftSyntaxMacros
    import SwiftSyntaxMacrosTestSupport
    import XCTest

    private let isRecording = false

    final class AllOfMacroTests: XCTestCase {
        func test_AllOfCodable() throws {
            withMacroTesting(
                isRecording: isRecording,
                macros: [
                    "AllOfCodable": AllOfCodableMacro.self,
                    "OmitCoding": OmitCodingMacro.self,
                ]
            ) {
                assertMacro {
                    """
                    @AllOfCodable
                    enum A {}
                    """
                } diagnostics: {
                    """
                    @AllOfCodable
                    ┬────────────
                    ╰─ 🛑 'AllOfCodable' macro can only be applied to a struct or to a class
                    enum A {}
                    """
                }

                assertMacro {
                    """
                    @AllOfCodable
                    struct A {
                        let brand: Brand
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    struct A {
                        let brand: Brand
                        let company: Company
                    }

                    extension A: Decodable, Encodable {
                        init(from decoder: Decoder) throws {
                            let container = try decoder.singleValueContainer()
                            self.brand = try container.decode(Brand.self)
                            self.company = try container.decode(Company.self)
                        }
                        func encode(to encoder: Encoder) throws {
                            try self.brand.encode(to: encoder)
                            try self.company.encode(to: encoder)
                        }
                    }
                    """
                }

                assertMacro {
                    """
                    @AllOfCodable
                    struct A: Encodable {
                        let brand: Brand
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    struct A: Encodable {
                        let brand: Brand
                        let company: Company
                    }

                    extension A: Decodable {
                        init(from decoder: Decoder) throws {
                            let container = try decoder.singleValueContainer()
                            self.brand = try container.decode(Brand.self)
                            self.company = try container.decode(Company.self)
                        }
                    }
                    """
                }

                assertMacro {
                    """
                    @AllOfCodable
                    struct A {
                        let brand: Brand?
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    struct A {
                        let brand: Brand?
                        let company: Company
                    }

                    extension A: Decodable, Encodable {
                        init(from decoder: Decoder) throws {
                            let container = try decoder.singleValueContainer()
                            self.brand = try container.decodeIfPresent(Brand.self)
                            self.company = try container.decode(Company.self)
                        }
                        func encode(to encoder: Encoder) throws {
                            try self.brand.encodeIfPresent(to: encoder)
                            try self.company.encode(to: encoder)
                        }
                    }
                    """
                }

                assertMacro {
                    """
                    @AllOfCodable
                    struct A: Decodable {
                        let brand: Brand
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    struct A: Decodable {
                        let brand: Brand
                        let company: Company
                    }

                    extension A: Encodable {
                        func encode(to encoder: Encoder) throws {
                            try self.brand.encode(to: encoder)
                            try self.company.encode(to: encoder)
                        }
                    }
                    """
                }

                assertMacro {
                    """
                    @AllOfCodable
                    struct A: Codable {
                        let brand: Brand
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    struct A: Codable {
                        let brand: Brand
                        let company: Company
                    }
                    """
                }

                assertMacro {
                    """
                    @AllOfCodable
                    public struct A {
                        let brand: Brand
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    public struct A {
                        let brand: Brand
                        let company: Company
                    }

                    extension A: Decodable, Encodable {
                        public init(from decoder: Decoder) throws {
                            let container = try decoder.singleValueContainer()
                            self.brand = try container.decode(Brand.self)
                            self.company = try container.decode(Company.self)
                        }
                        public func encode(to encoder: Encoder) throws {
                            try self.brand.encode(to: encoder)
                            try self.company.encode(to: encoder)
                        }
                    }
                    """
                }

                assertMacro {
                    """
                    @AllOfCodable
                    private struct A {
                        let brand: Brand
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    private struct A {
                        let brand: Brand
                        let company: Company
                    }

                    extension A: Decodable, Encodable {
                        init(from decoder: Decoder) throws {
                            let container = try decoder.singleValueContainer()
                            self.brand = try container.decode(Brand.self)
                            self.company = try container.decode(Company.self)
                        }
                        func encode(to encoder: Encoder) throws {
                            try self.brand.encode(to: encoder)
                            try self.company.encode(to: encoder)
                        }
                    }
                    """
                }

                assertMacro {
                    """
                    @AllOfCodable
                    private struct A {
                        let brand: Brand
                        @OmitCoding
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    private struct A {
                        let brand: Brand
                        let company: Company
                    }

                    extension A: Decodable, Encodable {
                        init(from decoder: Decoder) throws {
                            let container = try decoder.singleValueContainer()
                            self.brand = try container.decode(Brand.self)
                        }
                        func encode(to encoder: Encoder) throws {
                            try self.brand.encode(to: encoder)
                        }
                    }
                    """
                }

                assertMacro {
                    """
                    @AllOfCodable
                    private struct A {
                        @OmitCoding
                        let brand: Brand
                        @OmitCoding
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    private struct A {
                        let brand: Brand
                        let company: Company
                    }

                    extension A: Decodable, Encodable {
                        init(from decoder: Decoder) throws {
                        }
                        func encode(to encoder: Encoder) throws {
                        }
                    }
                    """
                }
            }
        }

        func test_AllOfDecodable() throws {
            withMacroTesting(
                isRecording: isRecording,
                macros: [
                    "AllOfDecodable": AllOfDecodableMacro.self,
                    "OmitCoding": OmitCodingMacro.self,
                ]
            ) {
                assertMacro {
                    """
                    @AllOfDecodable
                    enum A {}
                    """
                } diagnostics: {
                    """
                    @AllOfDecodable
                    ┬──────────────
                    ╰─ 🛑 'AllOfDecodable' macro can only be applied to a struct or to a class
                    enum A {}
                    """
                }

                assertMacro {
                    """
                    @AllOfDecodable
                    struct A {
                        let brand: Brand
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    struct A {
                        let brand: Brand
                        let company: Company
                    }

                    extension A: Decodable {
                        init(from decoder: Decoder) throws {
                            let container = try decoder.singleValueContainer()
                            self.brand = try container.decode(Brand.self)
                            self.company = try container.decode(Company.self)
                        }
                    }
                    """
                }

                assertMacro {
                    """
                    @AllOfDecodable
                    struct A: Encodable {
                        let brand: Brand
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    struct A: Encodable {
                        let brand: Brand
                        let company: Company
                    }

                    extension A: Decodable {
                        init(from decoder: Decoder) throws {
                            let container = try decoder.singleValueContainer()
                            self.brand = try container.decode(Brand.self)
                            self.company = try container.decode(Company.self)
                        }
                    }
                    """
                }

                assertMacro {
                    """
                    @AllOfDecodable
                    struct A: Decodable {
                        let brand: Brand
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    struct A: Decodable {
                        let brand: Brand
                        let company: Company
                    }
                    """
                }

                assertMacro {
                    """
                    @AllOfDecodable
                    struct A: Codable {
                        let brand: Brand
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    struct A: Codable {
                        let brand: Brand
                        let company: Company
                    }
                    """
                }

                assertMacro {
                    """
                    @AllOfDecodable
                    public struct A {
                        let brand: Brand
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    public struct A {
                        let brand: Brand
                        let company: Company
                    }

                    extension A: Decodable {
                        public init(from decoder: Decoder) throws {
                            let container = try decoder.singleValueContainer()
                            self.brand = try container.decode(Brand.self)
                            self.company = try container.decode(Company.self)
                        }
                    }
                    """
                }

                assertMacro {
                    """
                    @AllOfDecodable
                    private struct A {
                        let brand: Brand
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    private struct A {
                        let brand: Brand
                        let company: Company
                    }

                    extension A: Decodable {
                        init(from decoder: Decoder) throws {
                            let container = try decoder.singleValueContainer()
                            self.brand = try container.decode(Brand.self)
                            self.company = try container.decode(Company.self)
                        }
                    }
                    """
                }

                assertMacro {
                    """
                    @AllOfDecodable
                    private struct A {
                        let brand: Brand
                        @OmitCoding
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    private struct A {
                        let brand: Brand
                        let company: Company
                    }

                    extension A: Decodable {
                        init(from decoder: Decoder) throws {
                            let container = try decoder.singleValueContainer()
                            self.brand = try container.decode(Brand.self)
                        }
                    }
                    """
                }

                assertMacro {
                    """
                    @AllOfDecodable
                    private struct A {
                        @OmitCoding
                        let brand: Brand
                        @OmitCoding
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    private struct A {
                        let brand: Brand
                        let company: Company
                    }

                    extension A: Decodable {
                        init(from decoder: Decoder) throws {
                        }
                    }
                    """
                }
            }
        }

        func test_AllOfEncodable() throws {
            withMacroTesting(
                isRecording: isRecording,
                macros: [
                    "AllOfEncodable": AllOfEncodableMacro.self,
                    "OmitCoding": OmitCodingMacro.self,
                ]
            ) {
                assertMacro {
                    """
                    @AllOfEncodable
                    enum A {}
                    """
                } diagnostics: {
                    """
                    @AllOfEncodable
                    ┬──────────────
                    ╰─ 🛑 'AllOfEncodable' macro can only be applied to a struct or to a class
                    enum A {}
                    """
                }

                assertMacro {
                    """
                    @AllOfEncodable
                    struct A {
                        let brand: Brand
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    struct A {
                        let brand: Brand
                        let company: Company
                    }

                    extension A: Encodable {
                        func encode(to encoder: Encoder) throws {
                            try self.brand.encode(to: encoder)
                            try self.company.encode(to: encoder)
                        }
                    }
                    """
                }

                assertMacro {
                    """
                    @AllOfEncodable
                    struct A: Encodable {
                        let brand: Brand
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    struct A: Encodable {
                        let brand: Brand
                        let company: Company
                    }
                    """
                }

                assertMacro {
                    """
                    @AllOfEncodable
                    struct A: Decodable {
                        let brand: Brand
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    struct A: Decodable {
                        let brand: Brand
                        let company: Company
                    }

                    extension A: Encodable {
                        func encode(to encoder: Encoder) throws {
                            try self.brand.encode(to: encoder)
                            try self.company.encode(to: encoder)
                        }
                    }
                    """
                }

                assertMacro {
                    """
                    @AllOfEncodable
                    struct A: Codable {
                        let brand: Brand
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    struct A: Codable {
                        let brand: Brand
                        let company: Company
                    }
                    """
                }

                assertMacro {
                    """
                    @AllOfEncodable
                    public struct A {
                        let brand: Brand
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    public struct A {
                        let brand: Brand
                        let company: Company
                    }

                    extension A: Encodable {
                        public func encode(to encoder: Encoder) throws {
                            try self.brand.encode(to: encoder)
                            try self.company.encode(to: encoder)
                        }
                    }
                    """
                }

                assertMacro {
                    """
                    @AllOfEncodable
                    private struct A {
                        let brand: Brand
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    private struct A {
                        let brand: Brand
                        let company: Company
                    }

                    extension A: Encodable {
                        func encode(to encoder: Encoder) throws {
                            try self.brand.encode(to: encoder)
                            try self.company.encode(to: encoder)
                        }
                    }
                    """
                }

                assertMacro {
                    """
                    @AllOfEncodable
                    private struct A {
                        let brand: Brand
                        @OmitCoding
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    private struct A {
                        let brand: Brand
                        let company: Company
                    }

                    extension A: Encodable {
                        func encode(to encoder: Encoder) throws {
                            try self.brand.encode(to: encoder)
                        }
                    }
                    """
                }

                assertMacro {
                    """
                    @AllOfEncodable
                    private struct A {
                        @OmitCoding
                        let brand: Brand
                        @OmitCoding
                        let company: Company
                    }
                    """
                } expansion: {
                    """
                    private struct A {
                        let brand: Brand
                        let company: Company
                    }

                    extension A: Encodable {
                        func encode(to encoder: Encoder) throws {
                        }
                    }
                    """
                }
            }
        }
    }
#endif
