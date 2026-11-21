//
//  Catalog.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/21/26.
//

import SwiftUI

enum Slot: String, CaseIterable {
    case sky, treeLeft, treeRight, house, lantern, pool, float, friend, ground, head

    var isOutfit: Bool { self == .head }

    var korean: String {
        switch self {
        case .sky: "하늘"
        case .treeLeft: "왼쪽 나무"
        case .treeRight: "오른쪽 나무"
        case .house: "집"
        case .lantern: "등불"
        case .pool: "온천"
        case .float: "물 위"
        case .friend: "친구"
        case .ground: "마당"
        case .head: "모자"
        }
    }

    var english: String {
        switch self {
        case .sky: "Sky"
        case .treeLeft: "Left tree"
        case .treeRight: "Right tree"
        case .house: "House"
        case .lantern: "Lantern"
        case .pool: "Hot spring"
        case .float: "Floating"
        case .friend: "Friend"
        case .ground: "Garden"
        case .head: "Hat"
        }
    }

    var tint: Color {
        switch self {
        case .sky: .blue
        case .treeLeft, .treeRight, .ground: .green
        case .house: .brown
        case .lantern: .orange
        case .pool, .float: .teal
        case .friend: .yellow
        case .head: .pink
        }
    }
}

enum Unlock: Hashable {
    case starter
    case price(Int)
    case streak(Int)
    case plus
    case pro
}

struct Item: Identifiable, Hashable {
    let id: String
    let korean: String
    let english: String
    let emoji: String
    let slot: Slot
    let unlock: Unlock
}

enum Catalog {
    static let items: [Item] = [
        Item(id: "tree_tangerine", korean: "귤나무", english: "Tangerine tree", emoji: "🌳", slot: .treeRight, unlock: .starter),
        Item(id: "tree_apple", korean: "사과나무", english: "Apple tree", emoji: "🍎", slot: .treeRight, unlock: .price(250)),
        Item(id: "tree_mugunghwa", korean: "무궁화", english: "Rose of Sharon", emoji: "🌺", slot: .treeRight, unlock: .price(400)),
        Item(id: "tree_persimmon", korean: "감나무", english: "Persimmon tree", emoji: "🍑", slot: .treeRight, unlock: .price(450)),
        Item(id: "tree_plum", korean: "매화나무", english: "Plum blossom", emoji: "🌸", slot: .treeRight, unlock: .price(600)),
        Item(id: "tree_magnolia", korean: "목련", english: "Magnolia", emoji: "🌷", slot: .treeRight, unlock: .price(700)),
        Item(id: "tree_snowy", korean: "눈 덮인 나무", english: "Snowy tree", emoji: "❄️", slot: .treeRight, unlock: .price(1200)),
        Item(id: "tree_cherry", korean: "벚꽃나무", english: "Cherry tree", emoji: "🌸", slot: .treeRight, unlock: .price(1500)),
        Item(id: "tree_wisteria", korean: "등나무", english: "Wisteria", emoji: "💜", slot: .treeRight, unlock: .price(1800)),
        Item(id: "tree_golden", korean: "황금나무", english: "Golden tree", emoji: "🌟", slot: .treeRight, unlock: .price(4500)),
        Item(id: "tree_star", korean: "별나무", english: "Star tree", emoji: "⭐", slot: .treeRight, unlock: .streak(60)),
        Item(id: "tree_maple", korean: "단풍나무", english: "Maple tree", emoji: "🍁", slot: .treeRight, unlock: .plus),
        Item(id: "tree_moonlight", korean: "달빛나무", english: "Moonlight tree", emoji: "🌙", slot: .treeRight, unlock: .pro),

        Item(id: "tree_pine", korean: "소나무", english: "Pine tree", emoji: "🌲", slot: .treeLeft, unlock: .starter),
        Item(id: "tree_cypress", korean: "측백나무", english: "Cypress", emoji: "🌲", slot: .treeLeft, unlock: .price(150)),
        Item(id: "tree_cactus", korean: "선인장", english: "Cactus", emoji: "🌵", slot: .treeLeft, unlock: .price(200)),
        Item(id: "tree_birch", korean: "자작나무", english: "Birch", emoji: "🌳", slot: .treeLeft, unlock: .price(450)),
        Item(id: "tree_ginkgo", korean: "은행나무", english: "Ginkgo tree", emoji: "🍂", slot: .treeLeft, unlock: .price(600)),
        Item(id: "tree_palm", korean: "야자수", english: "Palm tree", emoji: "🌴", slot: .treeLeft, unlock: .price(700)),
        Item(id: "tree_willow", korean: "버드나무", english: "Willow", emoji: "🌿", slot: .treeLeft, unlock: .price(1200)),
        Item(id: "tree_snowpine", korean: "눈 소나무", english: "Snowy pine", emoji: "🌨️", slot: .treeLeft, unlock: .price(1500)),
        Item(id: "tree_bonsai", korean: "분재", english: "Bonsai", emoji: "🪴", slot: .treeLeft, unlock: .price(4000)),
        Item(id: "tree_bamboo", korean: "대나무", english: "Bamboo", emoji: "🎋", slot: .treeLeft, unlock: .streak(7)),
        Item(id: "tree_holiday", korean: "크리스마스 트리", english: "Holiday tree", emoji: "🎄", slot: .treeLeft, unlock: .plus),

        Item(id: "house_nest", korean: "짚 둥지", english: "Straw nest", emoji: "🪺", slot: .house, unlock: .starter),
        Item(id: "house_tent", korean: "텐트", english: "Tent", emoji: "⛺", slot: .house, unlock: .price(150)),
        Item(id: "house_hut", korean: "나무 집", english: "Little wood hut", emoji: "🛖", slot: .house, unlock: .price(250)),
        Item(id: "house_wondumak", korean: "원두막", english: "Lookout hut", emoji: "🛖", slot: .house, unlock: .price(450)),
        Item(id: "house_choga", korean: "초가집", english: "Thatched cottage", emoji: "🏡", slot: .house, unlock: .price(600)),
        Item(id: "house_igloo", korean: "이글루", english: "Igloo", emoji: "🧊", slot: .house, unlock: .price(700)),
        Item(id: "house_lighthouse", korean: "등대", english: "Lighthouse", emoji: "🗼", slot: .house, unlock: .price(1200)),
        Item(id: "house_mushroom", korean: "버섯 집", english: "Mushroom house", emoji: "🍄", slot: .house, unlock: .streak(14)),
        Item(id: "house_treehouse", korean: "나무 위 집", english: "Treehouse", emoji: "🌳", slot: .house, unlock: .price(1500)),
        Item(id: "house_giwa", korean: "기와집", english: "Tiled house", emoji: "🏯", slot: .house, unlock: .price(1800)),
        Item(id: "house_hanok", korean: "한옥", english: "Hanok", emoji: "🏯", slot: .house, unlock: .price(2000)),
        Item(id: "house_spaceship", korean: "우주선", english: "Spaceship", emoji: "🛸", slot: .house, unlock: .price(4500)),
        Item(id: "house_palace", korean: "궁궐", english: "Palace gate", emoji: "🏯", slot: .house, unlock: .price(5000)),
        Item(id: "house_tangerine", korean: "귤 오두막", english: "Tangerine cottage", emoji: "🍊", slot: .house, unlock: .plus),
        Item(id: "house_moonpavilion", korean: "달빛 정자", english: "Moon pavilion", emoji: "🌙", slot: .house, unlock: .pro),

        Item(id: "lantern_stone", korean: "석등", english: "Stone lantern", emoji: "🗿", slot: .lantern, unlock: .starter),
        Item(id: "lantern_candle", korean: "촛불", english: "Candle", emoji: "🕯️", slot: .lantern, unlock: .price(100)),
        Item(id: "lantern_paper", korean: "종이 등", english: "Paper lantern", emoji: "🏮", slot: .lantern, unlock: .price(120)),
        Item(id: "lantern_silk", korean: "청사초롱", english: "Silk lantern", emoji: "🏮", slot: .lantern, unlock: .price(200)),
        Item(id: "lantern_oil", korean: "호롱불", english: "Oil lamp", emoji: "🪔", slot: .lantern, unlock: .streak(3)),
        Item(id: "lantern_firefly", korean: "반딧불 병", english: "Firefly jar", emoji: "✨", slot: .lantern, unlock: .price(450)),
        Item(id: "lantern_mushroom", korean: "버섯 등", english: "Mushroom lamp", emoji: "🍄", slot: .lantern, unlock: .price(600)),
        Item(id: "lantern_star", korean: "별 등", english: "Star lamp", emoji: "🌟", slot: .lantern, unlock: .price(1200)),
        Item(id: "lantern_lotus", korean: "연등", english: "Lotus lantern", emoji: "🪷", slot: .lantern, unlock: .price(1800)),
        Item(id: "lantern_dragon", korean: "용 등", english: "Dragon lantern", emoji: "🐉", slot: .lantern, unlock: .price(5000)),
        Item(id: "lantern_rainbow", korean: "무지개 등", english: "Rainbow lantern", emoji: "🌈", slot: .lantern, unlock: .pro),

        Item(id: "sky_clouds", korean: "구름", english: "Clouds", emoji: "☁️", slot: .sky, unlock: .price(100)),
        Item(id: "sky_birds", korean: "새 떼", english: "Birds", emoji: "🐦", slot: .sky, unlock: .price(150)),
        Item(id: "sky_kite", korean: "연", english: "Kite", emoji: "🪁", slot: .sky, unlock: .price(150)),
        Item(id: "sky_sun", korean: "해님", english: "Sunshine", emoji: "☀️", slot: .sky, unlock: .price(200)),
        Item(id: "sky_petals", korean: "꽃잎 바람", english: "Petal breeze", emoji: "🌸", slot: .sky, unlock: .price(400)),
        Item(id: "sky_stars", korean: "별자리", english: "Constellation", emoji: "✨", slot: .sky, unlock: .price(450)),
        Item(id: "sky_balloon", korean: "열기구", english: "Hot-air balloon", emoji: "🎈", slot: .sky, unlock: .price(600)),
        Item(id: "sky_moon", korean: "보름달", english: "Full moon", emoji: "🌕", slot: .sky, unlock: .price(700)),
        Item(id: "sky_plane", korean: "비행기", english: "Little plane", emoji: "✈️", slot: .sky, unlock: .price(1200)),
        Item(id: "sky_crane", korean: "학", english: "Crane", emoji: "🕊️", slot: .sky, unlock: .streak(14)),
        Item(id: "sky_comet", korean: "혜성", english: "Comet", emoji: "☄️", slot: .sky, unlock: .price(1500)),
        Item(id: "sky_rainbow", korean: "무지개", english: "Rainbow", emoji: "🌈", slot: .sky, unlock: .streak(30)),
        Item(id: "sky_fireworks", korean: "불꽃놀이", english: "Fireworks", emoji: "🎆", slot: .sky, unlock: .price(4500)),
        Item(id: "sky_phoenix", korean: "봉황", english: "Phoenix", emoji: "🦚", slot: .sky, unlock: .price(5000)),
        Item(id: "sky_aurora", korean: "오로라", english: "Aurora", emoji: "🌌", slot: .sky, unlock: .plus),

        Item(id: "pool_spring", korean: "온천", english: "Hot spring", emoji: "♨️", slot: .pool, unlock: .starter),
        Item(id: "pool_bubbles", korean: "거품 온천", english: "Bubble bath", emoji: "🫧", slot: .pool, unlock: .price(100)),
        Item(id: "pool_lilypads", korean: "연잎", english: "Lily pads", emoji: "🍃", slot: .pool, unlock: .price(150)),
        Item(id: "pool_mugwort", korean: "쑥탕", english: "Mugwort bath", emoji: "🌿", slot: .pool, unlock: .price(250)),
        Item(id: "pool_petals", korean: "꽃잎 온천", english: "Petal bath", emoji: "🌺", slot: .pool, unlock: .price(400)),
        Item(id: "pool_ice", korean: "얼음 온천", english: "Ice bath", emoji: "🧊", slot: .pool, unlock: .price(450)),
        Item(id: "pool_milk", korean: "우유탕", english: "Milk bath", emoji: "🥛", slot: .pool, unlock: .price(600)),
        Item(id: "pool_yuzu", korean: "유자탕", english: "Yuzu bath", emoji: "🍋", slot: .pool, unlock: .price(1200)),
        Item(id: "pool_ginseng", korean: "인삼탕", english: "Ginseng bath", emoji: "🫚", slot: .pool, unlock: .price(1800)),
        Item(id: "pool_starry", korean: "별빛 온천", english: "Starlight spring", emoji: "🌠", slot: .pool, unlock: .streak(30)),
        Item(id: "pool_gold", korean: "금빛 온천", english: "Golden spring", emoji: "✨", slot: .pool, unlock: .price(5000)),
        Item(id: "pool_rainbow", korean: "무지개 온천", english: "Rainbow spring", emoji: "🌈", slot: .pool, unlock: .pro),

        Item(id: "float_duck", korean: "고무오리", english: "Rubber duck", emoji: "🐥", slot: .float, unlock: .price(100)),
        Item(id: "float_paperboat", korean: "종이배", english: "Paper boat", emoji: "⛵", slot: .float, unlock: .price(120)),
        Item(id: "float_tangerines", korean: "귤 둥둥", english: "Floating tangerines", emoji: "🍊", slot: .float, unlock: .price(150)),
        Item(id: "float_beachball", korean: "비치볼", english: "Beach ball", emoji: "🏐", slot: .float, unlock: .price(150)),
        Item(id: "float_lotus", korean: "연꽃", english: "Lotus flower", emoji: "🪷", slot: .float, unlock: .price(200)),
        Item(id: "float_ring", korean: "튜브", english: "Swim ring", emoji: "🛟", slot: .float, unlock: .price(200)),
        Item(id: "float_watermelon", korean: "수박", english: "Watermelon", emoji: "🍉", slot: .float, unlock: .price(250)),
        Item(id: "float_frog", korean: "개구리", english: "Lily frog", emoji: "🐸", slot: .float, unlock: .streak(3)),
        Item(id: "float_turtle", korean: "거북이", english: "Turtle", emoji: "🐢", slot: .float, unlock: .price(450)),
        Item(id: "float_swan", korean: "백조 튜브", english: "Swan float", emoji: "🦢", slot: .float, unlock: .price(700)),
        Item(id: "float_treasure", korean: "보물상자", english: "Treasure chest", emoji: "🧰", slot: .float, unlock: .price(1500)),
        Item(id: "float_turtleship", korean: "거북선", english: "Turtle ship", emoji: "🚢", slot: .float, unlock: .price(4500)),
        Item(id: "float_crownduck", korean: "왕관 오리", english: "Royal duck", emoji: "🦆", slot: .float, unlock: .plus),

        Item(id: "friend_sparrow", korean: "참새", english: "Sparrow", emoji: "🐦", slot: .friend, unlock: .price(100)),
        Item(id: "friend_chick", korean: "병아리", english: "Chick", emoji: "🐤", slot: .friend, unlock: .price(120)),
        Item(id: "friend_squirrel", korean: "다람쥐", english: "Squirrel", emoji: "🐿️", slot: .friend, unlock: .price(200)),
        Item(id: "friend_rabbit", korean: "토끼", english: "Rabbit", emoji: "🐰", slot: .friend, unlock: .price(250)),
        Item(id: "friend_cat", korean: "고양이", english: "Cat", emoji: "🐱", slot: .friend, unlock: .price(450)),
        Item(id: "friend_jindo", korean: "진돗개", english: "Jindo dog", emoji: "🐕", slot: .friend, unlock: .price(600)),
        Item(id: "friend_hedgehog", korean: "고슴도치", english: "Hedgehog", emoji: "🦔", slot: .friend, unlock: .price(700)),
        Item(id: "friend_magpie", korean: "까치", english: "Magpie", emoji: "🐦‍⬛", slot: .friend, unlock: .streak(7)),
        Item(id: "friend_capybara", korean: "아기 카피바라", english: "Baby capybara", emoji: "🦫", slot: .friend, unlock: .price(1500)),
        Item(id: "friend_tangerinepup", korean: "귤 강아지", english: "Tangerine puppy", emoji: "🐶", slot: .friend, unlock: .plus),
        Item(id: "friend_tiger", korean: "아기 호랑이", english: "Tiger cub", emoji: "🐯", slot: .friend, unlock: .price(4000)),
        Item(id: "friend_haetae", korean: "해태", english: "Haetae", emoji: "🦁", slot: .friend, unlock: .pro),

        Item(id: "ground_flowers", korean: "꽃밭", english: "Flower bed", emoji: "🌷", slot: .ground, unlock: .price(100)),
        Item(id: "ground_stones", korean: "징검다리", english: "Stepping stones", emoji: "🪨", slot: .ground, unlock: .price(120)),
        Item(id: "ground_mushrooms", korean: "버섯", english: "Mushrooms", emoji: "🍄", slot: .ground, unlock: .price(150)),
        Item(id: "ground_sign", korean: "팻말", english: "Signpost", emoji: "🪧", slot: .ground, unlock: .price(200)),
        Item(id: "ground_pumpkins", korean: "호박", english: "Pumpkins", emoji: "🎃", slot: .ground, unlock: .price(250)),
        Item(id: "ground_jangdok", korean: "장독대", english: "Kimchi jars", emoji: "🏺", slot: .ground, unlock: .price(450)),
        Item(id: "ground_bench", korean: "벤치", english: "Bench", emoji: "🪑", slot: .ground, unlock: .price(600)),
        Item(id: "ground_snowman", korean: "눈사람", english: "Snowman", emoji: "⛄", slot: .ground, unlock: .price(700)),
        Item(id: "ground_bicycle", korean: "자전거", english: "Bicycle", emoji: "🚲", slot: .ground, unlock: .price(1200)),
        Item(id: "ground_well", korean: "우물", english: "Well", emoji: "🪣", slot: .ground, unlock: .price(1500)),
        Item(id: "ground_hareubang", korean: "돌하르방", english: "Dol hareubang", emoji: "🗿", slot: .ground, unlock: .price(4000)),
        Item(id: "ground_clover", korean: "네잎클로버", english: "Four-leaf clover", emoji: "🍀", slot: .ground, unlock: .streak(100)),

        Item(id: "head_ribbon", korean: "리본", english: "Ribbon", emoji: "🎀", slot: .head, unlock: .price(100)),
        Item(id: "head_headband", korean: "머리띠", english: "Headband", emoji: "🎀", slot: .head, unlock: .price(120)),
        Item(id: "head_cap", korean: "야구모자", english: "Baseball cap", emoji: "🧢", slot: .head, unlock: .price(150)),
        Item(id: "head_party", korean: "고깔모자", english: "Party hat", emoji: "🥳", slot: .head, unlock: .price(150)),
        Item(id: "head_beanie", korean: "털모자", english: "Beanie", emoji: "🧢", slot: .head, unlock: .price(200)),
        Item(id: "head_sunglasses", korean: "선글라스", english: "Sunglasses", emoji: "🕶️", slot: .head, unlock: .price(200)),
        Item(id: "head_chef", korean: "요리사 모자", english: "Chef hat", emoji: "👨‍🍳", slot: .head, unlock: .price(250)),
        Item(id: "head_flowers", korean: "화관", english: "Flower crown", emoji: "🌼", slot: .head, unlock: .price(450)),
        Item(id: "head_gat", korean: "갓", english: "Gat hat", emoji: "🎩", slot: .head, unlock: .price(600)),
        Item(id: "head_headphones", korean: "헤드폰", english: "Headphones", emoji: "🎧", slot: .head, unlock: .price(700)),
        Item(id: "head_jokduri", korean: "족두리", english: "Jokduri", emoji: "👑", slot: .head, unlock: .price(1800)),
        Item(id: "head_gradcap", korean: "학사모", english: "Graduation cap", emoji: "🎓", slot: .head, unlock: .streak(60)),
        Item(id: "head_tangerine", korean: "귤 모자", english: "Tangerine hat", emoji: "🍊", slot: .head, unlock: .plus),
        Item(id: "head_crown", korean: "왕관", english: "Crown", emoji: "👑", slot: .head, unlock: .pro),
    ]

    static func items(in slot: Slot) -> [Item] {
        items.filter { $0.slot == slot }
    }

    static func item(_ id: String) -> Item? {
        items.first { $0.id == id }
    }

    static func starter(for slot: Slot) -> Item? {
        items.first { $0.slot == slot && $0.unlock == .starter }
    }
}

enum Rarity {
    case common, uncommon, rare, legendary, special

    var label: String? {
        switch self {
        case .rare: "RARE"
        case .legendary: "LEGEND"
        default: nil
        }
    }

    var color: Color {
        switch self {
        case .rare: .blue
        case .legendary: .orange
        default: .clear
        }
    }
}

extension Item {
    var rarity: Rarity {
        switch unlock {
        case .price(let p) where p >= 4000: .legendary
        case .price(let p) where p >= 1000: .rare
        case .price(let p) where p >= 400: .uncommon
        case .price, .starter: .common
        case .streak, .plus, .pro: .special
        }
    }
}

enum ShopCategory: String, CaseIterable, Identifiable {
    case houses, trees, lanterns, sky, spring, floating, friends, garden, hats

    var id: Self { self }

    var slots: [Slot] {
        switch self {
        case .houses: [.house]
        case .trees: [.treeLeft, .treeRight]
        case .lanterns: [.lantern]
        case .sky: [.sky]
        case .spring: [.pool]
        case .floating: [.float]
        case .friends: [.friend]
        case .garden: [.ground]
        case .hats: [.head]
        }
    }

    var isOutfit: Bool { self == .hats }

    var korean: String {
        switch self {
        case .houses: "집"
        case .trees: "나무"
        case .lanterns: "등불"
        case .sky: "하늘"
        case .spring: "온천"
        case .floating: "물 위"
        case .friends: "친구"
        case .garden: "마당"
        case .hats: "모자"
        }
    }

    var english: String {
        switch self {
        case .houses: "Houses"
        case .trees: "Trees"
        case .lanterns: "Lanterns"
        case .sky: "Sky"
        case .spring: "Hot spring"
        case .floating: "Floating"
        case .friends: "Friends"
        case .garden: "Garden"
        case .hats: "Hats"
        }
    }
}

struct ItemArt: View {
    let item: Item

    var body: some View {
        if UIImage(named: item.id) != nil {
            Image(item.id)
                .resizable()
                .scaledToFit()
        } else {
            Text(item.emoji)
                .font(.system(size: 48))
        }
    }
}
