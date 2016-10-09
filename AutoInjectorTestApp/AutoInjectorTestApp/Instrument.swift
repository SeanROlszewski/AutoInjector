protocol Instrument {
    var brand: String { get set }
}

struct Guitar: Instrument {
    var brand: String
}
