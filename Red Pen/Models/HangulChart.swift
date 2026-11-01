import Foundation

struct Jamo: Identifiable {
    let letter: String
    let roman: String
    let sound: String

    var id: String { letter }
}

enum HangulChart {
    static let consonants: [Jamo] = [
        Jamo(letter: "ㄱ", roman: "g / k", sound: "가"),
        Jamo(letter: "ㄴ", roman: "n", sound: "나"),
        Jamo(letter: "ㄷ", roman: "d / t", sound: "다"),
        Jamo(letter: "ㄹ", roman: "r / l", sound: "라"),
        Jamo(letter: "ㅁ", roman: "m", sound: "마"),
        Jamo(letter: "ㅂ", roman: "b / p", sound: "바"),
        Jamo(letter: "ㅅ", roman: "s", sound: "사"),
        Jamo(letter: "ㅇ", roman: "silent / ng", sound: "아"),
        Jamo(letter: "ㅈ", roman: "j", sound: "자"),
        Jamo(letter: "ㅊ", roman: "ch", sound: "차"),
        Jamo(letter: "ㅋ", roman: "k", sound: "카"),
        Jamo(letter: "ㅌ", roman: "t", sound: "타"),
        Jamo(letter: "ㅍ", roman: "p", sound: "파"),
        Jamo(letter: "ㅎ", roman: "h", sound: "하"),
        Jamo(letter: "ㄲ", roman: "kk", sound: "까"),
        Jamo(letter: "ㄸ", roman: "tt", sound: "따"),
        Jamo(letter: "ㅃ", roman: "pp", sound: "빠"),
        Jamo(letter: "ㅆ", roman: "ss", sound: "싸"),
        Jamo(letter: "ㅉ", roman: "jj", sound: "짜"),
    ]

    static let vowels: [Jamo] = [
        Jamo(letter: "ㅏ", roman: "a", sound: "아"),
        Jamo(letter: "ㅑ", roman: "ya", sound: "야"),
        Jamo(letter: "ㅓ", roman: "eo", sound: "어"),
        Jamo(letter: "ㅕ", roman: "yeo", sound: "여"),
        Jamo(letter: "ㅗ", roman: "o", sound: "오"),
        Jamo(letter: "ㅛ", roman: "yo", sound: "요"),
        Jamo(letter: "ㅜ", roman: "u", sound: "우"),
        Jamo(letter: "ㅠ", roman: "yu", sound: "유"),
        Jamo(letter: "ㅡ", roman: "eu", sound: "으"),
        Jamo(letter: "ㅣ", roman: "i", sound: "이"),
        Jamo(letter: "ㅐ", roman: "ae", sound: "애"),
        Jamo(letter: "ㅒ", roman: "yae", sound: "얘"),
        Jamo(letter: "ㅔ", roman: "e", sound: "에"),
        Jamo(letter: "ㅖ", roman: "ye", sound: "예"),
        Jamo(letter: "ㅘ", roman: "wa", sound: "와"),
        Jamo(letter: "ㅙ", roman: "wae", sound: "왜"),
        Jamo(letter: "ㅚ", roman: "oe", sound: "외"),
        Jamo(letter: "ㅝ", roman: "wo", sound: "워"),
        Jamo(letter: "ㅞ", roman: "we", sound: "웨"),
        Jamo(letter: "ㅟ", roman: "wi", sound: "위"),
        Jamo(letter: "ㅢ", roman: "ui", sound: "의"),
    ]
}
