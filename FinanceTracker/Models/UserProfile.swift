import Foundation

struct UserProfile: Codable {
    var coffeeCost: Double
    var lunchCost: Double
    var dinnerCost: Double
    var groceriesWeekly: Double
    var transportationMonthly: Double

    // Derived estimates based on answers
    var estimatedCosts: [ExpenseCategory: Double] {
        var costs: [ExpenseCategory: Double] = [:]

        // Direct answers
        costs[.coffee] = coffeeCost
        costs[.lunch] = lunchCost
        costs[.dinner] = dinnerCost
        costs[.groceries] = groceriesWeekly / 7 // Daily grocery estimate

        // Transportation per trip estimate
        let transportPerTrip = transportationMonthly / 20 // Assuming 20 working days
        costs[.transportation] = transportPerTrip
        costs[.gas] = transportationMonthly / 4 // Weekly gas estimate

        // Derived estimates based on spending patterns
        let avgMealCost = (lunchCost + dinnerCost) / 2

        // Snacks typically 30-40% of a meal cost
        costs[.snacks] = avgMealCost * 0.35

        // Fast food between lunch and dinner cost
        costs[.fastFood] = (lunchCost + dinnerCost) / 2

        // Drinks similar to coffee or slightly more
        costs[.drinks] = coffeeCost * 1.2

        // Entertainment based on dinner cost (movie ticket ~ dinner)
        costs[.entertainment] = dinnerCost * 1.5

        // Shopping estimate based on weekly groceries
        costs[.shopping] = groceriesWeekly * 0.5

        // Parking estimate based on transportation
        costs[.parking] = transportPerTrip * 0.5

        // Utilities per day (assuming monthly ~$150-200 range scaled to user's spending)
        let spendingLevel = (coffeeCost + lunchCost + dinnerCost) / 3
        costs[.utilities] = spendingLevel * 3

        // Healthcare per visit estimate
        costs[.healthcare] = dinnerCost * 3

        // Subscriptions estimate (Netflix, Spotify range)
        costs[.subscriptions] = coffeeCost * 3

        // Other - average of common expenses
        costs[.other] = avgMealCost

        return costs
    }

    static var empty: UserProfile {
        UserProfile(
            coffeeCost: 0,
            lunchCost: 0,
            dinnerCost: 0,
            groceriesWeekly: 0,
            transportationMonthly: 0
        )
    }
}

struct QuestionnaireQuestion: Identifiable {
    let id = UUID()
    let question: String
    let category: QuestionCategory
    let hint: String
    let minValue: Double
    let maxValue: Double
    let defaultValue: Double

    enum QuestionCategory {
        case coffee
        case lunch
        case dinner
        case groceries
        case transportation
    }
}

extension QuestionnaireQuestion {
    static let allQuestions: [QuestionnaireQuestion] = [
        QuestionnaireQuestion(
            question: "How much do you typically spend on coffee?",
            category: .coffee,
            hint: "Think about your average coffee purchase",
            minValue: 1,
            maxValue: 15,
            defaultValue: 5
        ),
        QuestionnaireQuestion(
            question: "What's your usual lunch cost?",
            category: .lunch,
            hint: "Average workday lunch",
            minValue: 5,
            maxValue: 30,
            defaultValue: 12
        ),
        QuestionnaireQuestion(
            question: "How much do you spend on dinner?",
            category: .dinner,
            hint: "Average dinner out or takeout",
            minValue: 10,
            maxValue: 50,
            defaultValue: 20
        ),
        QuestionnaireQuestion(
            question: "What's your weekly grocery budget?",
            category: .groceries,
            hint: "Total weekly grocery shopping",
            minValue: 30,
            maxValue: 300,
            defaultValue: 100
        ),
        QuestionnaireQuestion(
            question: "Monthly transportation costs?",
            category: .transportation,
            hint: "Gas, transit passes, rideshare",
            minValue: 20,
            maxValue: 500,
            defaultValue: 150
        )
    ]
}
