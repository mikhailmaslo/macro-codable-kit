import MacroCodableKit

public struct OmitEmpty: CustomDecodingName {}

public protocol OmitEmptyCheckable {
    var omitEmpty_isEmpty: Bool { get }
}
