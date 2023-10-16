@Encodable
struct User {
    let name: String
    @CustomCoding(OmitEmpty)
    let followersCount: Int
    @CustomCoding(OmitEmpty)
    let isVerified: Bool
}
