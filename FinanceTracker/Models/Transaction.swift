import Foundation

struct Transaction: Identifiable, Codable {
    let id: UUID
    var amount: Double
    var category: ExpenseCategory
    var note: String
    var date: Date

    init(id: UUID = UUID(), amount: Double, category: ExpenseCategory, note: String = "", date: Date = Date()) {
        self.id = id
        self.amount = amount
        self.category = category
        self.note = note
        self.date = date
    }
}

enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
    case coffee = "Coffee"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case groceries = "Groceries"
    case transportation = "Transportation"
    case entertainment = "Entertainment"
    case shopping = "Shopping"
    case utilities = "Utilities"
    case healthcare = "Healthcare"
    case subscriptions = "Subscriptions"
    case snacks = "Snacks"
    case drinks = "Drinks"
    case fastFood = "Fast Food"
    case gas = "Gas"
    case parking = "Parking"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .coffee: return "cup.and.saucer.fill"
        case .lunch: return "fork.knife"
        case .dinner: return "fork.knife.circle.fill"
        case .groceries: return "cart.fill"
        case .transportation: return "bus.fill"
        case .entertainment: return "film.fill"
        case .shopping: return "bag.fill"
        case .utilities: return "bolt.fill"
        case .healthcare: return "cross.fill"
        case .subscriptions: return "repeat.circle.fill"
        case .snacks: return "birthday.cake.fill"
        case .drinks: return "wineglass.fill"
        case .fastFood: return "takeoutbag.and.cup.and.straw.fill"
        case .gas: return "fuelpump.fill"
        case .parking: return "parkingsign.circle.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    var color: String {
        switch self {
        case .coffee: return "brown"
        case .lunch: return "orange"
        case .dinner: return "red"
        case .groceries: return "green"
        case .transportation: return "blue"
        case .entertainment: return "purple"
        case .shopping: return "pink"
        case .utilities: return "yellow"
        case .healthcare: return "teal"
        case .subscriptions: return "indigo"
        case .snacks: return "mint"
        case .drinks: return "grape"
        case .fastFood: return "coral"
        case .gas: return "slate"
        case .parking: return "navy"
        case .other: return "gray"
        }
    }
}
