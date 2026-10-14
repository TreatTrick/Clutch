// Renders the Clutch app icon and menu bar icons (a keycap + a mouse) into Clutch/Assets.xcassets.
// Usage: swift scripts/make_icon.swift [output-dir]
import AppKit

let canvas: CGFloat = 1024

func color(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha)
}

/// Superellipse ("squircle") path like the macOS icon shape
func squircle(in rect: CGRect, exponent n: CGFloat = 5) -> CGPath {
    let path = CGMutablePath()
    let a = rect.width / 2, b = rect.height / 2
    let steps = 720
    for i in 0...steps {
        let t = CGFloat(i) / CGFloat(steps) * 2 * .pi
        let c = cos(t), s = sin(t)
        let x = pow(abs(c), 2 / n) * a * (c < 0 ? -1 : 1)
        let y = pow(abs(s), 2 / n) * b * (s < 0 ? -1 : 1)
        let point = CGPoint(x: rect.midX + x, y: rect.midY + y)
        i == 0 ? path.move(to: point) : path.addLine(to: point)
    }
    path.closeSubpath()
    return path
}

func roundedRect(_ rect: CGRect, _ radius: CGFloat) -> CGPath {
    CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
}

func fillGradient(_ ctx: CGContext, _ path: CGPath, top: CGColor, bottom: CGColor, in rect: CGRect) {
    ctx.saveGState()
    ctx.addPath(path)
    ctx.clip()
    let gradient = CGGradient(colorsSpace: CGColorSpace(name: CGColorSpace.sRGB),
                              colors: [top, bottom] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(gradient, start: CGPoint(x: rect.midX, y: rect.maxY),
                           end: CGPoint(x: rect.midX, y: rect.minY), options: [])
    ctx.restoreGState()
}

func drawIcon(_ ctx: CGContext) {
    // Background tile on the standard 824pt macOS icon grid, with a soft drop shadow
    let tile = CGRect(x: 100, y: 100, width: 824, height: 824)
    let tilePath = squircle(in: tile)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 28, color: color(0x000000, 0.35))
    ctx.addPath(tilePath)
    ctx.setFillColor(color(0x3A5BF0))
    ctx.fillPath()
    ctx.restoreGState()
    fillGradient(ctx, tilePath, top: color(0x5B8CFF), bottom: color(0x3436D6), in: tile)

    // Gentle sheen on the upper half
    ctx.saveGState()
    ctx.addPath(tilePath)
    ctx.clip()
    let sheen = CGGradient(colorsSpace: CGColorSpace(name: CGColorSpace.sRGB),
                           colors: [color(0xFFFFFF, 0.18), color(0xFFFFFF, 0)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(sheen, start: CGPoint(x: 512, y: tile.maxY), end: CGPoint(x: 512, y: 520), options: [])
    ctx.restoreGState()

    let objectShadow = color(0x10124A, 0.45)

    // Keycap: darker skirt below a white top face, with the ⌥ symbol
    let cap = CGRect(x: 176, y: 352, width: 300, height: 300)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -18), blur: 30, color: objectShadow)
    ctx.addPath(roundedRect(cap, 64))
    ctx.setFillColor(color(0xC9D2F2))
    ctx.fillPath()
    ctx.restoreGState()
    let face = CGRect(x: cap.minX + 18, y: cap.minY + 34, width: cap.width - 36, height: cap.height - 50)
    fillGradient(ctx, roundedRect(face, 50), top: color(0xFFFFFF), bottom: color(0xEEF1FB), in: face)

    let font = NSFont.systemFont(ofSize: 150, weight: .semibold)
    let glyph = NSAttributedString(string: "⌥", attributes: [
        .font: font,
        .foregroundColor: NSColor(cgColor: color(0x3436D6))!,
    ])
    let line = CTLineCreateWithAttributedString(glyph)
    let bounds = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)
    ctx.textPosition = CGPoint(x: face.midX - bounds.midX, y: face.midY - bounds.midY)
    CTLineDraw(line, ctx)

    // Plus sign between the two
    ctx.setFillColor(color(0xFFFFFF, 0.85))
    ctx.addPath(roundedRect(CGRect(x: 496, y: 494, width: 52, height: 18), 9))
    ctx.addPath(roundedRect(CGRect(x: 513, y: 477, width: 18, height: 52), 9))
    ctx.fillPath()

    // Mouse: white body, button split lines, and an amber side button that reads as "pressed"
    let mouse = CGRect(x: 588, y: 292, width: 264, height: 420)
    let body = roundedRect(mouse, 132)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -18), blur: 30, color: objectShadow)
    ctx.addPath(body)
    ctx.setFillColor(color(0xFFFFFF))
    ctx.fillPath()
    ctx.restoreGState()
    fillGradient(ctx, body, top: color(0xFFFFFF), bottom: color(0xE8ECFA), in: mouse)

    ctx.setStrokeColor(color(0xB8C2EA))
    ctx.setLineWidth(10)
    ctx.setLineCap(.round)
    let split = mouse.minY + mouse.height * 0.6
    ctx.move(to: CGPoint(x: mouse.minX + 14, y: split))
    ctx.addLine(to: CGPoint(x: mouse.maxX - 14, y: split))
    ctx.move(to: CGPoint(x: mouse.midX, y: split))
    ctx.addLine(to: CGPoint(x: mouse.midX, y: mouse.maxY - 8))
    ctx.strokePath()

    // Scroll wheel
    ctx.addPath(roundedRect(CGRect(x: mouse.midX - 17, y: split + 40, width: 34, height: 70), 17))
    ctx.setFillColor(color(0x3436D6))
    ctx.fillPath()

    // Side button, sticking out of the left edge
    ctx.saveGState()
    ctx.setShadow(offset: .zero, blur: 22, color: color(0xFFC53D, 0.9))
    ctx.addPath(roundedRect(CGRect(x: mouse.minX - 16, y: mouse.minY + 175, width: 34, height: 92), 17))
    ctx.setFillColor(color(0xFFB800))
    ctx.fillPath()
    ctx.restoreGState()
}

func render(pixels: Int) -> Data {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    let context = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.current = context
    let ctx = context.cgContext
    ctx.scaleBy(x: CGFloat(pixels) / canvas, y: CGFloat(pixels) / canvas)
    drawIcon(ctx)
    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

let output = URL(fileURLWithPath: CommandLine.arguments.count > 1
                 ? CommandLine.arguments[1]
                 : "Clutch/Assets.xcassets/AppIcon.appiconset")
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)

var images: [[String: String]] = []
for points in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let name = "icon_\(points)x\(points)\(scale == 2 ? "@2x" : "").png"
        try render(pixels: points * scale).write(to: output.appendingPathComponent(name))
        images.append(["idiom": "mac", "size": "\(points)x\(points)", "scale": "\(scale)x", "filename": name])
    }
}
let contents: [String: Any] = ["images": images, "info": ["author": "xcode", "version": 1]]
let json = try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
try json.write(to: output.appendingPathComponent("Contents.json"))

let catalog = output.deletingLastPathComponent().appendingPathComponent("Contents.json")
if !FileManager.default.fileExists(atPath: catalog.path) {
    try #"{"info":{"author":"xcode","version":1}}"#.write(to: catalog, atomically: true, encoding: .utf8)
}
print("wrote icon to \(output.path)")

// MARK: - Menu bar icon

/// Monochrome template image for the status item, 26×18 pt: a keycap and a mouse side by side.
/// `filled` is the enabled state; the outline variant is shown while Clutch is paused.
func drawMenuBarIcon(_ ctx: CGContext, filled: Bool) {
    let black = color(0x000000)
    let lineWidth: CGFloat = 1.5
    let cap = CGRect(x: 1, y: 3, width: 12, height: 12)
    let mouse = CGRect(x: 16, y: 1, width: 9, height: 16)
    let split = mouse.minY + mouse.height * 0.58

    if filled {
        ctx.setFillColor(black)
        ctx.addPath(roundedRect(cap, 3))
        ctx.addPath(roundedRect(mouse, 4.5))
        ctx.fillPath()

        // Punch the ⌥ symbol and the mouse button split out of the solid shapes
        ctx.setBlendMode(.clear)
        let glyph = NSAttributedString(string: "⌥", attributes: [
            .font: NSFont.systemFont(ofSize: 9.5, weight: .bold),
            .foregroundColor: NSColor.black,
        ])
        let line = CTLineCreateWithAttributedString(glyph)
        let bounds = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)
        ctx.textPosition = CGPoint(x: cap.midX - bounds.midX, y: cap.midY - bounds.midY)
        CTLineDraw(line, ctx)

        ctx.setStrokeColor(black)
        ctx.setLineWidth(1.2)
        ctx.move(to: CGPoint(x: mouse.minX, y: split))
        ctx.addLine(to: CGPoint(x: mouse.maxX, y: split))
        ctx.move(to: CGPoint(x: mouse.midX, y: split))
        ctx.addLine(to: CGPoint(x: mouse.midX, y: mouse.maxY))
        ctx.strokePath()
        ctx.setBlendMode(.normal)
    } else {
        ctx.setStrokeColor(black)
        ctx.setLineWidth(lineWidth)
        let inset = lineWidth / 2
        ctx.addPath(roundedRect(cap.insetBy(dx: inset, dy: inset), 2.5))
        ctx.addPath(roundedRect(mouse.insetBy(dx: inset, dy: inset), 3.8))
        ctx.move(to: CGPoint(x: mouse.minX + inset, y: split))
        ctx.addLine(to: CGPoint(x: mouse.maxX - inset, y: split))
        ctx.strokePath()

        let glyph = NSAttributedString(string: "⌥", attributes: [
            .font: NSFont.systemFont(ofSize: 8, weight: .semibold),
            .foregroundColor: NSColor.black,
        ])
        let line = CTLineCreateWithAttributedString(glyph)
        let bounds = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)
        ctx.textPosition = CGPoint(x: cap.midX - bounds.midX, y: cap.midY - bounds.midY)
        CTLineDraw(line, ctx)
    }
}

func renderMenuBarIcon(scale: Int, filled: Bool) -> Data {
    let size = (width: 26, height: 18)
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size.width * scale, pixelsHigh: size.height * scale,
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    let context = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.current = context
    context.cgContext.scaleBy(x: CGFloat(scale), y: CGFloat(scale))
    drawMenuBarIcon(context.cgContext, filled: filled)
    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

let catalogDir = output.deletingLastPathComponent()
for (name, filled) in [("MenuBarIcon", true), ("MenuBarIconOff", false)] {
    let set = catalogDir.appendingPathComponent("\(name).imageset")
    try FileManager.default.createDirectory(at: set, withIntermediateDirectories: true)
    var entries: [[String: String]] = []
    for scale in [1, 2, 3] {
        let file = "\(name)\(scale == 1 ? "" : "@\(scale)x").png"
        try renderMenuBarIcon(scale: scale, filled: filled).write(to: set.appendingPathComponent(file))
        entries.append(["idiom": "universal", "scale": "\(scale)x", "filename": file])
    }
    let setContents: [String: Any] = [
        "images": entries,
        "info": ["author": "xcode", "version": 1],
        // Template images follow the menu bar's light/dark appearance automatically
        "properties": ["template-rendering-intent": "template"],
    ]
    try JSONSerialization.data(withJSONObject: setContents, options: [.prettyPrinted, .sortedKeys])
        .write(to: set.appendingPathComponent("Contents.json"))
}
print("wrote menu bar icons to \(catalogDir.path)")
