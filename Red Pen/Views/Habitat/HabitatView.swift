//
//  HabitatView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/21/26.
//

import SwiftUI
import SwiftData

enum HabitatMood {
    case soaking, waiting, sleeping
}

enum SkyTime {
    case day, sunset, night

    static func at(_ date: Date) -> SkyTime {
        switch Calendar.current.component(.hour, from: date) {
        case 6..<17: .day
        case 17..<20: .sunset
        default: .night
        }
    }

    var sky: [Color] {
        switch self {
        case .day: [Color(hex: 0xBFE3F5), Color(hex: 0xE8F4F2), Color(hex: 0xFFF4E0)]
        case .sunset: [Color(hex: 0xF6B48F), Color(hex: 0xF9CDA7), Color(hex: 0xFCE3C4)]
        case .night: [Color(hex: 0x141F3A), Color(hex: 0x24365E), Color(hex: 0x3A4D7A)]
        }
    }

    var farHill: Color {
        switch self {
        case .day: Color(hex: 0xA9D49B)
        case .sunset: Color(hex: 0x9DBB86)
        case .night: Color(hex: 0x3E5C55)
        }
    }

    var nearHill: Color {
        switch self {
        case .day: Color(hex: 0x8CC47F)
        case .sunset: Color(hex: 0x84AE74)
        case .night: Color(hex: 0x33504A)
        }
    }

    var orb: Color {
        switch self {
        case .day: Color(hex: 0xFFD36B)
        case .sunset: Color(hex: 0xFF9F68)
        case .night: Color(hex: 0xF5F0D0)
        }
    }
}

extension Slot: Identifiable {
    var id: Self { self }

    var sceneFrame: CGRect {
        switch self {
        case .sky: CGRect(x: 112, y: 150, width: 150, height: 90)
        case .treeLeft: CGRect(x: 4, y: 228, width: 100, height: 184)
        case .treeRight: CGRect(x: 252, y: 254, width: 134, height: 170)
        case .house: CGRect(x: 102, y: 314, width: 150, height: 128)
        case .lantern: CGRect(x: 12, y: 432, width: 66, height: 92)
        case .pool: CGRect(x: 70, y: 478, width: 260, height: 100)
        case .float: CGRect(x: 150, y: 516, width: 100, height: 40)
        case .friend: CGRect(x: 16, y: 534, width: 60, height: 52)
        case .ground: CGRect(x: 312, y: 546, width: 74, height: 44)
        case .head: .zero
        }
    }

    var allowsEmpty: Bool { self != .pool }
}

struct HabitatView: View {
    @Environment(ProgressStore.self) private var progress
    @Environment(Wallet.self) private var wallet
    @Environment(ProStore.self) private var store
    @AppStorage("selectedTab") private var selectedTab = "home"
    @AppStorage("dailyGoal") private var dailyGoal = 10
    @Query private var corrections: [Correction]

    @State private var editing = false
    @State private var editingSlot: Slot?
    @State private var preview: (slot: Slot, id: String)?
    @State private var showShop = false
    @State private var gochiHops = 0

    private static let design = CGSize(width: 390, height: 844)

    private var mood: HabitatMood {
        if progress.practicedToday { return .soaking }
        let today = Calendar.current.startOfDay(for: .now)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let last = Date(timeIntervalSince1970: progress.lastPracticeDay)
        if progress.lastPracticeDay > 0 && last < yesterday { return .sleeping }
        return .waiting
    }

    private var dueCount: Int {
        corrections.filter { $0.dueDate <= .now }.count
    }

    private var answeredToday: Int {
        let today = Calendar.current.startOfDay(for: .now).timeIntervalSince1970
        return progress.todayCountDay == today ? progress.todayCount : 0
    }

    func shownItem(in slot: Slot) -> Item? {
        if let preview, preview.slot == slot {
            return preview.id.isEmpty ? nil : Catalog.item(preview.id)
        }
        guard let id = wallet.placedID(in: slot), !id.isEmpty, let item = Catalog.item(id) else {
            return nil
        }
        switch item.unlock {
        case .plus where store.tier < .plus, .pro where store.tier < .pro:
            return Catalog.starter(for: slot)
        default:
            return item
        }
    }

    var body: some View {
        TimelineView(.everyMinute) { context in
            let time = SkyTime.at(context.date)
            GeometryReader { geo in
                let sx = geo.size.width / Self.design.width
                let sy = geo.size.height / Self.design.height

                ZStack {
                    scene(time: time, sx: sx, sy: sy)
                    if editing { slotOutlines(sx: sx, sy: sy) }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .ignoresSafeArea()
            .overlay(alignment: .top) { topBar(time: time) }
            .overlay(alignment: .bottom) {
                if editing { editBanner } else { practiceCard }
            }
        }
        .sheet(item: $editingSlot, onDismiss: { preview = nil }) { slot in
            SlotPickerSheet(slot: slot, preview: Binding(
                get: { preview?.slot == slot ? preview?.id : nil },
                set: { id in preview = id.map { (slot, $0) } }
            ))
            .presentationDetents([.height(420)])
            .presentationBackgroundInteraction(.enabled(upThrough: .height(420)))
        }
        .sheet(isPresented: $showShop) {
            ShopView()
        }
    }

    // MARK: Scene

    private func place(_ r: CGRect, sx: CGFloat, sy: CGFloat) -> (CGSize, CGPoint) {
        let size = CGSize(width: r.width * sx, height: r.height * sx)
        let center = CGPoint(x: r.midX * sx, y: r.minY * sy + size.height / 2)
        return (size, center)
    }

    @ViewBuilder
    private func scene(time: SkyTime, sx: CGFloat, sy: CGFloat) -> some View {
        ZStack {
            LinearGradient(colors: time.sky, startPoint: .top, endPoint: .bottom)

            if time == .night { Stars(sx: sx, sy: sy) }

            Circle()
                .fill(time.orb)
                .frame(width: 66 * sx, height: 66 * sx)
                .shadow(color: time.orb, radius: 30)
                .position(x: 315 * sx, y: 151 * sy)

            Ellipse()
                .fill(time.farHill)
                .frame(width: 760 * sx, height: 320 * sx)
                .position(x: 200 * sx, y: 300 * sy + 160 * sx)
            Ellipse()
                .fill(time.nearHill)
                .frame(width: 640 * sx, height: 520 * sx)
                .position(x: 200 * sx, y: 380 * sy + 260 * sx)

            ForEach([Slot.sky, .treeLeft, .treeRight, .house, .lantern, .pool, .ground, .friend], id: \.self) { slot in
                if let item = shownItem(in: slot) {
                    let (size, center) = place(slot.sceneFrame, sx: sx, sy: sy)
                    ItemArt(item: item)
                        .frame(width: size.width, height: size.height, alignment: .bottom)
                        .position(center)
                        .transition(.scale(scale: 0.6).combined(with: .opacity))
                        .id(item.id)
                }
            }

            gochi(sx: sx, sy: sy)

            if let item = shownItem(in: .float) {
                let (size, center) = place(Slot.float.sceneFrame, sx: sx, sy: sy)
                ItemArt(item: item)
                    .frame(width: size.width, height: size.height)
                    .position(center)
                    .modifier(Bob(amount: 3))
                    .id(item.id)
            }

            if mood == .soaking {
                Steam()
                    .frame(width: 160 * sx, height: 60 * sx)
                    .position(x: 200 * sx, y: 470 * sy)
                    .allowsHitTesting(false)
            }
        }
        .animation(.snappy, value: preview?.id)
        .animation(.snappy, value: wallet.placed)
    }

    private func gochiFrame(sx: CGFloat, sy: CGFloat) -> CGRect {
        let r: CGRect = switch mood {
        case .soaking: CGRect(x: 118, y: 388, width: 154, height: 154)
        case .waiting: CGRect(x: 214, y: 404, width: 136, height: 136)
        case .sleeping: CGRect(x: 226, y: 376, width: 140, height: 140)
        }
        return CGRect(x: r.minX * sx, y: r.minY * sy, width: r.width * sx, height: r.height * sx)
    }

    @ViewBuilder
    private func gochi(sx: CGFloat, sy: CGFloat) -> some View {
        let f = gochiFrame(sx: sx, sy: sy)
        DressedGochi(
            xp: progress.xp,
            hop: gochiHops,
            mood: mood == .sleeping ? .sleepy : (mood == .soaking ? .happy : .awake),
            hat: shownItem(in: .head)
        )
        .frame(width: f.width, height: f.height)
        .mask {
            if mood == .soaking {
                Rectangle().padding(.bottom, f.height * 0.32)
            } else {
                Rectangle()
            }
        }
        .modifier(Bob(amount: mood == .sleeping ? 1.5 : 3))
        .opacity(editing ? 0.35 : 1)
        .position(x: f.midX, y: f.midY)
        .onTapGesture { gochiHops += 1 }
        .sensoryFeedback(.impact(weight: .light), trigger: gochiHops)
        .accessibilityLabel("Gochi")
        .accessibilityAddTraits(.isButton)
    }

    // MARK: Edit mode

    @ViewBuilder
    private func slotOutlines(sx: CGFloat, sy: CGFloat) -> some View {
        let g = gochiFrame(sx: sx, sy: sy)
        let gochiSlots: [(Slot, CGRect)] = [
            (.head, CGRect(x: g.minX + g.width * 0.22, y: g.minY + g.height * 0.05, width: g.width * 0.56, height: g.height * 0.36)),
        ]
        let sceneSlots: [(Slot, CGRect)] = [Slot.sky, .treeLeft, .treeRight, .house, .lantern, .pool, .float, .friend, .ground].map { slot in
            let (size, center) = place(slot.sceneFrame, sx: sx, sy: sy)
            return (slot, CGRect(x: center.x - size.width / 2, y: center.y - size.height / 2, width: size.width, height: size.height))
        }
        ForEach(sceneSlots + gochiSlots, id: \.0) { slot, rect in
            Button {
                editingSlot = slot
            } label: {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(editingSlot == slot ? Color.gochiRed : .white,
                                  style: StrokeStyle(lineWidth: editingSlot == slot ? 3 : 2, dash: editingSlot == slot ? [] : [6, 5]))
                    .background(Color.white.opacity(0.12), in: .rect(cornerRadius: 14))
                    .overlay(alignment: .topLeading) {
                        Text(slot.english)
                            .font(.caption2.bold())
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(editingSlot == slot ? Color.gochiRed : .white, in: .capsule)
                            .foregroundStyle(editingSlot == slot ? .white : .primary)
                            .offset(x: 6, y: -9)
                    }
            }
            .buttonStyle(.plain)
            .frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
            .accessibilityLabel("\(slot.english) spot")
        }
    }

    // MARK: Overlays

    private func topBar(time: SkyTime) -> some View {
        HStack(spacing: 8) {
            chip {
                Image(systemName: "flame.fill").foregroundStyle(Color.gochiRed)
                Text("\(mood == .sleeping ? 0 : progress.streak)").font(.headline)
            }
            Spacer()
            Button { showShop = true } label: {
                chip {
                    Text("🍊")
                    Text(wallet.balance.formatted())
                        .font(.headline)
                        .contentTransition(.numericText())
                }
            }
            .buttonStyle(PressableStyle())
            .accessibilityLabel("Shop, \(wallet.balance) tangerines")

            Button {
                withAnimation(.snappy) {
                    editing.toggle()
                    if !editing { editingSlot = nil }
                }
            } label: {
                chip {
                    Image(systemName: editing ? "checkmark" : "paintbrush.pointed.fill")
                        .foregroundStyle(editing ? Color.green : Color.primary)
                }
            }
            .buttonStyle(PressableStyle())
            .accessibilityLabel(editing ? "Done editing" : "Edit room")
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .animation(.snappy, value: wallet.balance)
    }

    private func chip<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        HStack(spacing: 5) { content() }
            .padding(.horizontal, 12)
            .frame(height: 38)
            .background(.regularMaterial, in: .capsule)
    }

    private var bubble: (title: String, subtitle: String) {
        switch mood {
        case .soaking: ("따뜻해요~", "You practiced today. Gochi is relaxing.")
        case .waiting: ("같이 공부해요!", dueCount > 0 ? "\(dueCount) mistakes are ready" : "Add a mistake to practice")
        case .sleeping: ("쿨쿨…", "Practice to wake Gochi up")
        }
    }

    private var practiceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: bubble.title)
                    .font(.title3.bold())
                Text(bubble.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 12) {
                ProgressView(value: Double(min(answeredToday, dailyGoal)), total: Double(max(dailyGoal, 1)))
                    .tint(answeredToday >= dailyGoal ? .green : Color.gochiRed)
                Text("\(answeredToday) / \(dailyGoal)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Button {
                selectedTab = "practice"
            } label: {
                Text(dueCount > 0 ? "Practice now" : "Go to practice")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundStyle(.white)
                    .background(Color.gochiRed, in: .capsule)
            }
            .buttonStyle(PressableStyle())
        }
        .padding(18)
        .background(.regularMaterial, in: .rect(cornerRadius: 26))
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private var editBanner: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Edit your room").font(.headline)
                Text("Tap a dashed spot to change it").font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Button("Done") {
                withAnimation(.snappy) { editing = false; editingSlot = nil }
            }
            .font(.headline)
            .buttonStyle(.borderedProminent)
            .tint(Color.gochiRed)
        }
        .padding(18)
        .background(.regularMaterial, in: .rect(cornerRadius: 26))
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

// MARK: Pieces

struct DressedGochi: View {
    let xp: Int
    var hop: Int = 0
    var mood: GochiMood = .awake
    var hat: Item?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geo in
            let form = GochiForm.forXP(xp)
            let artH = min(geo.size.height, geo.size.width * 212 / 220)
            let artW = artH * 220 / 212
            let x0 = (geo.size.width - artW) / 2
            let y0 = (geo.size.height - artH) / 2

            let b = GochiFit.bounds(form.assetName)
            let bx = x0 + artW * b.minX
            let by = y0 + artH * b.minY
            let bw = artW * b.width
            let bh = artH * b.height

            ZStack {
                GochiView(xp: xp, mood: mood)

                if let hat {
                    ItemArt(item: hat)
                        .frame(width: bw * 0.62, height: bh * 0.32)
                        .position(x: bx + bw / 2, y: by + bh * 0.04)
                }
            }
            .keyframeAnimator(initialValue: 0.0, trigger: reduceMotion ? 0 : hop) { view, jump in
                view.offset(y: jump * geo.size.height / 160)
            } keyframes: { _ in
                CubicKeyframe(0, duration: 0.08)
                CubicKeyframe(-25, duration: 0.15)
                CubicKeyframe(0, duration: 0.15)
                CubicKeyframe(-10, duration: 0.1)
                CubicKeyframe(0, duration: 0.1)
            }
        }
    }
}

@MainActor
enum GochiFit {
    private static var cache: [String: CGRect] = [:]

    static func bounds(_ name: String) -> CGRect {
        if let cached = cache[name] { return cached }
        var result = CGRect(x: 0, y: 0, width: 1, height: 1)

        if let ui = UIImage(named: name) {
            let flat = UIGraphicsImageRenderer(size: ui.size).image { _ in ui.draw(at: .zero) }
            if let cg = flat.cgImage {
                let w = cg.width, h = cg.height
                var pixels = [UInt8](repeating: 0, count: w * h * 4)
                let drawn: Bool = pixels.withUnsafeMutableBytes { buffer in
                    guard let ctx = CGContext(data: buffer.baseAddress, width: w, height: h,
                                              bitsPerComponent: 8, bytesPerRow: w * 4,
                                              space: CGColorSpaceCreateDeviceRGB(),
                                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return false }
                    ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))
                    return true
                }
                if drawn {
                    var minX = w, minY = h, maxX = -1, maxY = -1
                    for y in 0..<h {
                        for x in 0..<w where pixels[(y * w + x) * 4 + 3] > 20 {
                            minX = min(minX, x); maxX = max(maxX, x)
                            minY = min(minY, y); maxY = max(maxY, y)
                        }
                    }
                    if maxX >= minX {
                        result = CGRect(x: CGFloat(minX) / CGFloat(w),
                                        y: CGFloat(minY) / CGFloat(h),
                                        width: CGFloat(maxX - minX + 1) / CGFloat(w),
                                        height: CGFloat(maxY - minY + 1) / CGFloat(h))
                    }
                }
            }
        }
        cache[name] = result
        return result
    }
}

struct Bob: ViewModifier {
    var amount: CGFloat
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.phaseAnimator([false, true]) { view, up in
            view.offset(y: reduceMotion ? 0 : (up ? -amount : 0))
        } animation: { _ in
            .easeInOut(duration: 1.6)
        }
    }
}

struct Stars: View {
    let sx: CGFloat
    let sy: CGFloat
    private let points: [CGPoint] = [
        CGPoint(x: 40, y: 120), CGPoint(x: 96, y: 70), CGPoint(x: 160, y: 140), CGPoint(x: 210, y: 96),
        CGPoint(x: 250, y: 190), CGPoint(x: 70, y: 200), CGPoint(x: 350, y: 230), CGPoint(x: 300, y: 60),
    ]

    var body: some View {
        ForEach(points.indices, id: \.self) { i in
            Circle()
                .fill(Color(hex: 0xFFF8D6))
                .frame(width: 3, height: 3)
                .phaseAnimator([0.3, 1.0]) { view, o in view.opacity(o) } animation: { _ in
                    .easeInOut(duration: 1.2 + Double(i % 3) * 0.4)
                }
                .position(x: points[i].x * sx, y: points[i].y * sy)
        }
        .accessibilityHidden(true)
    }
}

struct Steam: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if !reduceMotion {
            HStack(spacing: 30) {
                ForEach(0..<3, id: \.self) { i in
                    Capsule()
                        .fill(.white)
                        .frame(width: 14, height: 40)
                        .blur(radius: 3)
                        .keyframeAnimator(initialValue: 0.0, repeating: true) { view, t in
                            view.opacity(t < 0.4 ? t * 1.5 : (1 - t) * 1.0)
                                .offset(y: -t * 30)
                                .scaleEffect(0.8 + t * 0.4)
                        } keyframes: { _ in
                            LinearKeyframe(0.0, duration: Double(i) * 0.9)
                            LinearKeyframe(1.0, duration: 3.0)
                        }
                }
            }
            .accessibilityHidden(true)
        }
    }
}

#Preview {
    HabitatView()
        .modelContainer(for: [Correction.self, Folder.self], inMemory: true)
        .environment(ProgressStore())
        .environment(Wallet())
        .environment(ProStore())
}
