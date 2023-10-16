import MacroCodableKit

public struct OmitEmpty: CustomDecodingName {}

public protocol OmitEmptyCheckable {
    var omitEmpty_isEmpty: Bool { get }
}

extension Bool: OmitEmptyCheckable {
    public var omitEmpty_isEmpty: Bool { self == false }
}

extension String: OmitEmptyCheckable {
    public var omitEmpty_isEmpty: Bool { isEmpty }
}

extension Int: OmitEmptyCheckable {
    public var omitEmpty_isEmpty: Bool { self == 0 }
}

// etc ...
