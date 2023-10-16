@Encodable
struct User {
    let name: String
    @CustomCoding(OmitEmpty)
    let followersCount: Int
    @CustomCoding(OmitEmpty)
    let isVerified: Bool
}

let user = User(name: "Mikhail", followersCount: 0, isVerified: false)
// followersCount, isVerified won't be included
// {"name": "Mikhail"}
let data = try JSONEncoder().encode(user)
