// Turns the two mascot videos into transparent frame sequences bundled with the app.
//
//   swift scripts/make_mascot.swift <videoA.mp4> <videoB.mp4>
//
// Video A: dejected → overjoyed (scrubbed by the mouse). Video B: overjoyed → jump → back (loops).
// Each frame's background is removed with Vision's subject lifting, B is aligned to A, everything is
// placed on one shared canvas, scaled down, and written as one multi-image HEIC per clip.
import AVFoundation
import CoreImage
import ImageIO
import UniformTypeIdentifiers
import Vision

let outputHeight = 560 // px; shown at 280 pt on Retina
let quality = 0.72
let outputDir = URL(fileURLWithPath: "Clutch/Mascot")

let args = CommandLine.arguments
guard args.count == 3 else {
    print("usage: swift scripts/make_mascot.swift <videoA.mp4> <videoB.mp4>")
    exit(1)
}

func frames(of path: String) async throws -> [CGImage] {
    let asset = AVURLAsset(url: URL(fileURLWithPath: path))
    guard let track = try await asset.loadTracks(withMediaType: .video).first else { return [] }
    let fps = try await track.load(.nominalFrameRate)
    let duration = try await asset.load(.duration).seconds
    let generator = AVAssetImageGenerator(asset: asset)
    generator.requestedTimeToleranceBefore = .zero
    generator.requestedTimeToleranceAfter = .zero
    generator.appliesPreferredTrackTransform = true

    var images: [CGImage] = []
    let count = Int((duration * Double(fps)).rounded(.down))
    for i in 0..<count {
        let time = CMTime(value: CMTimeValue(i), timescale: CMTimeScale(fps.rounded()))
        images.append(try await generator.image(at: time).image)
    }
    return images
}

let ciContext = CIContext()

/// Removes the background, keeping every subject instance (character, sign, wings, tail)
func cutOut(_ image: CGImage) throws -> CGImage {
    let handler = VNImageRequestHandler(cgImage: image)
    let request = VNGenerateForegroundInstanceMaskRequest()
    try handler.perform([request])
    guard let result = request.results?.first else { return image }
    let buffer = try result.generateMaskedImage(ofInstances: result.allInstances, from: handler,
                                                croppedToInstancesExtent: false)
    let ci = CIImage(cvPixelBuffer: buffer)
    return ciContext.createCGImage(ci, from: ci.extent)!
}

/// Bounding box of non-transparent pixels, in top-left-origin pixel coordinates
func opaqueBounds(_ image: CGImage) -> CGRect {
    let w = image.width, h = image.height
    var pixels = [UInt8](repeating: 0, count: w * h * 4)
    let ctx = CGContext(data: &pixels, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                        space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h))
    var minX = w, minY = h, maxX = -1, maxY = -1
    for y in 0..<h {
        for x in 0..<w where pixels[(y * w + x) * 4 + 3] > 24 {
            minX = min(minX, x); maxX = max(maxX, x)
            minY = min(minY, y); maxY = max(maxY, y)
        }
    }
    guard maxX >= 0 else { return .null }
    // CGContext rows start at the bottom; flip to top-left origin
    return CGRect(x: minX, y: h - 1 - maxY, width: maxX - minX + 1, height: maxY - minY + 1)
}

/// Draws a frame into the output canvas. `rect` is where the whole source frame lands, in
/// top-left-origin output pixels.
func render(_ image: CGImage, in rect: CGRect, size: CGSize) -> CGImage {
    let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8,
                        bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.interpolationQuality = .high
    ctx.draw(image, in: CGRect(x: rect.minX, y: size.height - rect.maxY, width: rect.width, height: rect.height))
    return ctx.makeImage()!
}

func write(_ images: [CGImage], to url: URL) {
    let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.heic.identifier as CFString, images.count, nil)!
    for image in images {
        CGImageDestinationAddImage(dest, image, [kCGImageDestinationLossyCompressionQuality: quality] as CFDictionary)
    }
    precondition(CGImageDestinationFinalize(dest), "failed to write \(url.path)")
}

var clips: [[CGImage]] = []
for path in args.dropFirst() {
    let source = try await frames(of: path)
    print("\(path): \(source.count) frames, cutting out…")
    clips.append(try source.map(cutOut))
}

// The clips were generated separately, so the character isn't the same size in both. Map B onto
// A's coordinates by matching B's first (standing) frame to A's last frame: same height, same
// feet position, same horizontal center. That makes the A → B hand-off seamless.
let endOfA = opaqueBounds(clips[0].last!)
let startOfB = opaqueBounds(clips[1].first!)
let bScale = endOfA.height / startOfB.height
let transforms = [
    CGAffineTransform.identity,
    CGAffineTransform(translationX: endOfA.midX - startOfB.midX * bScale,
                      y: endOfA.maxY - startOfB.maxY * bScale).scaledBy(x: bScale, y: bScale),
]
print(String(format: "aligning B to A: scale %.3f", bScale))

// One shared canvas that fits every frame of both clips, padded a little
var box = CGRect.null
for (clip, transform) in zip(clips, transforms) {
    for frame in clip { box = box.union(opaqueBounds(frame).applying(transform)) }
}
box = box.insetBy(dx: -8, dy: -8).integral
let scale = CGFloat(outputHeight) / box.height
let size = CGSize(width: (box.width * scale).rounded(), height: CGFloat(outputHeight))
print("canvas \(box) → \(Int(size.width))×\(Int(size.height))")

/// Where a whole source frame lands in the output canvas
func placement(of frame: CGImage, _ transform: CGAffineTransform) -> CGRect {
    CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        .applying(transform)
        .applying(CGAffineTransform(translationX: -box.minX, y: -box.minY))
        .applying(CGAffineTransform(scaleX: scale, y: scale))
}

try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
for ((clip, transform), name) in zip(zip(clips, transforms), ["MascotA", "MascotB"]) {
    let url = outputDir.appendingPathComponent("\(name).heic")
    write(clip.map { render($0, in: placement(of: $0, transform), size: size) }, to: url)
    let bytes = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int) ?? 0
    print("wrote \(url.path) (\(clip.count) frames, \(bytes / 1024) KB)")
}
