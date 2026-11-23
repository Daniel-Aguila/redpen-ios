import SwiftUI

struct GochiStyle: Identifiable, Hashable {
    enum Category: String, CaseIterable, Identifiable {
        case wardrobe, hanbok, themes, world, zodiac, animals, holidays, costumes

        var id: Self { self }

        var title: LocalizedStringKey {
            switch self {
            case .wardrobe: "Korea"
            case .hanbok: "Hanbok"
            case .themes: "Jobs & fun"
            case .world: "Around the world"
            case .zodiac: "Zodiac"
            case .animals: "Animals"
            case .holidays: "Holidays"
            case .costumes: "Costumes"
            }
        }

        var emoji: String {
            switch self {
            case .wardrobe: "🇰🇷"
            case .hanbok: "👘"
            case .themes: "🧑‍🍳"
            case .world: "🌏"
            case .zodiac: "🐉"
            case .animals: "🐼"
            case .holidays: "🎃"
            case .costumes: "🚀"
            }
        }
    }

    enum Unlock: Hashable {
        case tangerines(Int)
        case streak(Int)
        case plus
        case pro
    }

    let id: String
    let name: String
    let category: Category
    let unlock: Unlock

    var imageName: String { "style-\(id)" }
}

enum StyleCatalog {
    static let all: [GochiStyle] = [
        GochiStyle(id: "wardrobe-hanbok-baji", name: String(localized: "Hanbok (baji)"), category: .wardrobe, unlock: .streak(7)),
        GochiStyle(id: "wardrobe-hanbok-chima", name: String(localized: "Hanbok (chima)"), category: .wardrobe, unlock: .streak(14)),
        GochiStyle(id: "wardrobe-wedding-groom", name: String(localized: "Wedding: groom"), category: .wardrobe, unlock: .tangerines(2000)),
        GochiStyle(id: "wardrobe-wedding-bride", name: String(localized: "Wedding: bride"), category: .wardrobe, unlock: .tangerines(2000)),
        GochiStyle(id: "wardrobe-queen", name: String(localized: "Queen"), category: .wardrobe, unlock: .tangerines(4000)),
        GochiStyle(id: "wardrobe-general", name: String(localized: "General"), category: .wardrobe, unlock: .tangerines(4000)),
        GochiStyle(id: "wardrobe-pungmul", name: String(localized: "Pungmul"), category: .wardrobe, unlock: .tangerines(1200)),
        GochiStyle(id: "wardrobe-haenyeo", name: String(localized: "Haenyeo"), category: .wardrobe, unlock: .tangerines(1200)),
        GochiStyle(id: "wardrobe-school-a", name: String(localized: "School A"), category: .wardrobe, unlock: .tangerines(1200)),
        GochiStyle(id: "wardrobe-school-b", name: String(localized: "School B"), category: .wardrobe, unlock: .tangerines(1200)),
        GochiStyle(id: "wardrobe-idol-a", name: String(localized: "Idol A"), category: .wardrobe, unlock: .plus),
        GochiStyle(id: "wardrobe-idol-b", name: String(localized: "Idol B"), category: .wardrobe, unlock: .plus),
        GochiStyle(id: "wardrobe-office", name: String(localized: "Office"), category: .wardrobe, unlock: .tangerines(1200)),
        GochiStyle(id: "wardrobe-hiker", name: String(localized: "Hiker"), category: .wardrobe, unlock: .tangerines(1200)),
        GochiStyle(id: "wardrobe-jjimjilbang", name: String(localized: "Jjimjilbang"), category: .wardrobe, unlock: .tangerines(1200)),
        GochiStyle(id: "wardrobe-ramyeon-night", name: String(localized: "Ramyeon night"), category: .wardrobe, unlock: .tangerines(1200)),
        GochiStyle(id: "wardrobe-winter", name: String(localized: "Winter"), category: .wardrobe, unlock: .tangerines(1200)),
        GochiStyle(id: "wardrobe-rainy-day", name: String(localized: "Rainy day"), category: .wardrobe, unlock: .tangerines(1200)),
        GochiStyle(id: "wardrobe-taekwondo", name: String(localized: "Taekwondo"), category: .wardrobe, unlock: .tangerines(1200)),
        GochiStyle(id: "wardrobe-graduation", name: String(localized: "Graduation"), category: .wardrobe, unlock: .tangerines(1200)),
        GochiStyle(id: "wardrobe-tiger", name: String(localized: "Tiger"), category: .wardrobe, unlock: .tangerines(4000)),
        GochiStyle(id: "wardrobe-dokkaebi", name: String(localized: "Dokkaebi"), category: .wardrobe, unlock: .tangerines(4000)),
        GochiStyle(id: "wardrobe-gumiho", name: String(localized: "Gumiho"), category: .wardrobe, unlock: .tangerines(4000)),
        GochiStyle(id: "wardrobe-gold-gochi", name: String(localized: "Gold Gochi"), category: .wardrobe, unlock: .pro),
        GochiStyle(id: "hanbok-first-birthday-a", name: String(localized: "First birthday A"), category: .hanbok, unlock: .tangerines(700)),
        GochiStyle(id: "hanbok-first-birthday-b", name: String(localized: "First birthday B"), category: .hanbok, unlock: .tangerines(700)),
        GochiStyle(id: "hanbok-saekdong-a", name: String(localized: "Saekdong A"), category: .hanbok, unlock: .tangerines(700)),
        GochiStyle(id: "hanbok-saekdong-b", name: String(localized: "Saekdong B"), category: .hanbok, unlock: .tangerines(700)),
        GochiStyle(id: "hanbok-prince", name: String(localized: "Prince"), category: .hanbok, unlock: .tangerines(2000)),
        GochiStyle(id: "hanbok-princess", name: String(localized: "Princess"), category: .hanbok, unlock: .tangerines(2000)),
        GochiStyle(id: "hanbok-court-lady", name: String(localized: "Court lady"), category: .hanbok, unlock: .tangerines(2000)),
        GochiStyle(id: "hanbok-dopo", name: String(localized: "Dopo"), category: .hanbok, unlock: .tangerines(700)),
        GochiStyle(id: "hanbok-durumagi", name: String(localized: "Durumagi"), category: .hanbok, unlock: .tangerines(700)),
        GochiStyle(id: "hanbok-baeja", name: String(localized: "Baeja"), category: .hanbok, unlock: .tangerines(700)),
        GochiStyle(id: "hanbok-jangot", name: String(localized: "Jangot"), category: .hanbok, unlock: .tangerines(700)),
        GochiStyle(id: "hanbok-seollal", name: String(localized: "Seollal"), category: .hanbok, unlock: .tangerines(700)),
        GochiStyle(id: "hanbok-modern-a", name: String(localized: "Modern A"), category: .hanbok, unlock: .tangerines(700)),
        GochiStyle(id: "hanbok-modern-b", name: String(localized: "Modern B"), category: .hanbok, unlock: .tangerines(700)),
        GochiStyle(id: "hanbok-spring", name: String(localized: "Spring"), category: .hanbok, unlock: .tangerines(700)),
        GochiStyle(id: "hanbok-night", name: String(localized: "Night"), category: .hanbok, unlock: .tangerines(700)),
        GochiStyle(id: "themes-chef", name: String(localized: "Chef"), category: .themes, unlock: .tangerines(700)),
        GochiStyle(id: "themes-barista", name: String(localized: "Barista"), category: .themes, unlock: .tangerines(700)),
        GochiStyle(id: "themes-delivery-rider", name: String(localized: "Delivery rider"), category: .themes, unlock: .tangerines(700)),
        GochiStyle(id: "themes-doctor", name: String(localized: "Doctor"), category: .themes, unlock: .tangerines(700)),
        GochiStyle(id: "themes-tteokbokki-stall", name: String(localized: "Tteokbokki stall"), category: .themes, unlock: .tangerines(700)),
        GochiStyle(id: "themes-kimbap", name: String(localized: "Kimbap"), category: .themes, unlock: .tangerines(700)),
        GochiStyle(id: "themes-fried-chicken", name: String(localized: "Fried chicken"), category: .themes, unlock: .tangerines(700)),
        GochiStyle(id: "themes-bibimbap", name: String(localized: "Bibimbap"), category: .themes, unlock: .tangerines(700)),
        GochiStyle(id: "themes-baseball-fan", name: String(localized: "Baseball fan"), category: .themes, unlock: .tangerines(700)),
        GochiStyle(id: "themes-archer", name: String(localized: "Archer"), category: .themes, unlock: .tangerines(700)),
        GochiStyle(id: "themes-football-fan", name: String(localized: "Football fan"), category: .themes, unlock: .tangerines(700)),
        GochiStyle(id: "themes-esports", name: String(localized: "Esports"), category: .themes, unlock: .tangerines(700)),
        GochiStyle(id: "themes-chuseok", name: String(localized: "Chuseok"), category: .themes, unlock: .tangerines(700)),
        GochiStyle(id: "themes-christmas", name: String(localized: "Christmas"), category: .themes, unlock: .tangerines(700)),
        GochiStyle(id: "themes-birthday", name: String(localized: "Birthday"), category: .themes, unlock: .tangerines(700)),
        GochiStyle(id: "themes-hangul-day", name: String(localized: "Hangul Day"), category: .themes, unlock: .tangerines(700)),
        GochiStyle(id: "themes-magpie", name: String(localized: "Magpie"), category: .themes, unlock: .tangerines(700)),
        GochiStyle(id: "themes-haetae", name: String(localized: "Haetae"), category: .themes, unlock: .tangerines(700)),
        GochiStyle(id: "themes-bear", name: String(localized: "Bear"), category: .themes, unlock: .tangerines(700)),
        GochiStyle(id: "themes-moon-rabbit", name: String(localized: "Moon rabbit"), category: .themes, unlock: .pro),
        GochiStyle(id: "world-mariachi", name: String(localized: "Mariachi"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-folklorico", name: String(localized: "Folklorico"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-catrina", name: String(localized: "Catrina"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-catrin", name: String(localized: "Catrin"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-luchador", name: String(localized: "Luchador"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-tehuana", name: String(localized: "Tehuana"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-japan", name: String(localized: "Japan"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-china", name: String(localized: "China"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-vietnam", name: String(localized: "Vietnam"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-thailand", name: String(localized: "Thailand"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-india", name: String(localized: "India"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-philippines", name: String(localized: "Philippines"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-indonesia", name: String(localized: "Indonesia"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-mongolia", name: String(localized: "Mongolia"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-scotland", name: String(localized: "Scotland"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-united-kingdom", name: String(localized: "United Kingdom"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-netherlands", name: String(localized: "Netherlands"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-germany", name: String(localized: "Germany"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-france", name: String(localized: "France"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-spain", name: String(localized: "Spain"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-italy", name: String(localized: "Italy"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-greece", name: String(localized: "Greece"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-russia", name: String(localized: "Russia"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-ukraine", name: String(localized: "Ukraine"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-sweden", name: String(localized: "Sweden"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-egypt", name: String(localized: "Egypt"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-morocco", name: String(localized: "Morocco"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-nigeria", name: String(localized: "Nigeria"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-ghana", name: String(localized: "Ghana"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-kenya", name: String(localized: "Kenya"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-united-states", name: String(localized: "United States"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-canada", name: String(localized: "Canada"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-brazil", name: String(localized: "Brazil"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-argentina", name: String(localized: "Argentina"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-peru", name: String(localized: "Peru"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "world-colombia", name: String(localized: "Colombia"), category: .world, unlock: .tangerines(1200)),
        GochiStyle(id: "zodiac-rat", name: String(localized: "Rat"), category: .zodiac, unlock: .tangerines(2000)),
        GochiStyle(id: "zodiac-ox", name: String(localized: "Ox"), category: .zodiac, unlock: .tangerines(2000)),
        GochiStyle(id: "zodiac-tiger", name: String(localized: "Tiger"), category: .zodiac, unlock: .tangerines(2000)),
        GochiStyle(id: "zodiac-rabbit", name: String(localized: "Rabbit"), category: .zodiac, unlock: .tangerines(2000)),
        GochiStyle(id: "zodiac-dragon", name: String(localized: "Dragon"), category: .zodiac, unlock: .tangerines(2000)),
        GochiStyle(id: "zodiac-snake", name: String(localized: "Snake"), category: .zodiac, unlock: .tangerines(2000)),
        GochiStyle(id: "zodiac-horse", name: String(localized: "Horse"), category: .zodiac, unlock: .tangerines(2000)),
        GochiStyle(id: "zodiac-goat", name: String(localized: "Goat"), category: .zodiac, unlock: .tangerines(2000)),
        GochiStyle(id: "zodiac-monkey", name: String(localized: "Monkey"), category: .zodiac, unlock: .tangerines(2000)),
        GochiStyle(id: "zodiac-rooster", name: String(localized: "Rooster"), category: .zodiac, unlock: .tangerines(2000)),
        GochiStyle(id: "zodiac-dog", name: String(localized: "Dog"), category: .zodiac, unlock: .tangerines(2000)),
        GochiStyle(id: "zodiac-pig", name: String(localized: "Pig"), category: .zodiac, unlock: .tangerines(2000)),
        GochiStyle(id: "animals-panda", name: String(localized: "Panda"), category: .animals, unlock: .tangerines(1200)),
        GochiStyle(id: "animals-cat", name: String(localized: "Cat"), category: .animals, unlock: .tangerines(1200)),
        GochiStyle(id: "animals-frog", name: String(localized: "Frog"), category: .animals, unlock: .tangerines(1200)),
        GochiStyle(id: "animals-penguin", name: String(localized: "Penguin"), category: .animals, unlock: .tangerines(1200)),
        GochiStyle(id: "animals-chick", name: String(localized: "Chick"), category: .animals, unlock: .tangerines(1200)),
        GochiStyle(id: "animals-bee", name: String(localized: "Bee"), category: .animals, unlock: .tangerines(1200)),
        GochiStyle(id: "animals-dinosaur", name: String(localized: "Dinosaur"), category: .animals, unlock: .tangerines(1200)),
        GochiStyle(id: "animals-shark", name: String(localized: "Shark"), category: .animals, unlock: .tangerines(1200)),
        GochiStyle(id: "animals-unicorn", name: String(localized: "Unicorn"), category: .animals, unlock: .tangerines(2000)),
        GochiStyle(id: "animals-fox", name: String(localized: "Fox"), category: .animals, unlock: .tangerines(1200)),
        GochiStyle(id: "animals-koala", name: String(localized: "Koala"), category: .animals, unlock: .tangerines(1200)),
        GochiStyle(id: "animals-axolotl", name: String(localized: "Axolotl"), category: .animals, unlock: .tangerines(2000)),
        GochiStyle(id: "holidays-new-year-s-eve", name: String(localized: "New Year's Eve"), category: .holidays, unlock: .tangerines(700)),
        GochiStyle(id: "holidays-valentine-s-day", name: String(localized: "Valentine's Day"), category: .holidays, unlock: .tangerines(700)),
        GochiStyle(id: "holidays-children-s-day", name: String(localized: "Children's Day"), category: .holidays, unlock: .tangerines(700)),
        GochiStyle(id: "holidays-parents-day", name: String(localized: "Parents' Day"), category: .holidays, unlock: .tangerines(700)),
        GochiStyle(id: "holidays-pumpkin", name: String(localized: "Pumpkin"), category: .holidays, unlock: .tangerines(700)),
        GochiStyle(id: "holidays-ghost", name: String(localized: "Ghost"), category: .holidays, unlock: .tangerines(700)),
        GochiStyle(id: "holidays-witch", name: String(localized: "Witch"), category: .holidays, unlock: .tangerines(700)),
        GochiStyle(id: "holidays-vampire", name: String(localized: "Vampire"), category: .holidays, unlock: .tangerines(700)),
        GochiStyle(id: "holidays-summer", name: String(localized: "Summer"), category: .holidays, unlock: .tangerines(700)),
        GochiStyle(id: "holidays-autumn", name: String(localized: "Autumn"), category: .holidays, unlock: .tangerines(700)),
        GochiStyle(id: "holidays-snowman", name: String(localized: "Snowman"), category: .holidays, unlock: .tangerines(700)),
        GochiStyle(id: "holidays-black-day", name: String(localized: "Black Day"), category: .holidays, unlock: .tangerines(700)),
        GochiStyle(id: "costumes-pajamas", name: String(localized: "Pajamas"), category: .costumes, unlock: .tangerines(700)),
        GochiStyle(id: "costumes-astronaut", name: String(localized: "Astronaut"), category: .costumes, unlock: .plus),
        GochiStyle(id: "costumes-mermaid", name: String(localized: "Mermaid"), category: .costumes, unlock: .tangerines(2000)),
        GochiStyle(id: "costumes-superhero", name: String(localized: "Superhero"), category: .costumes, unlock: .tangerines(700)),
        GochiStyle(id: "costumes-strawberry", name: String(localized: "Strawberry"), category: .costumes, unlock: .tangerines(700)),
        GochiStyle(id: "costumes-bubble-tea", name: String(localized: "Bubble tea"), category: .costumes, unlock: .tangerines(700)),
        GochiStyle(id: "costumes-sunflower", name: String(localized: "Sunflower"), category: .costumes, unlock: .tangerines(700)),
        GochiStyle(id: "costumes-mushroom", name: String(localized: "Mushroom"), category: .costumes, unlock: .tangerines(700)),
    ]

    static func style(_ id: String) -> GochiStyle? {
        all.first { $0.id == id }
    }

    static func styles(in category: GochiStyle.Category) -> [GochiStyle] {
        all.filter { $0.category == category }
    }
}
