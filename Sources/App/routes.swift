import Vapor
import Vision
import AppKit

func routes(_ app: Application) throws {
    app.get { req async throws -> View in
        return try await req.view.render("index")
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    app.post("ocr2json") { req async throws -> Response in
        // 从请求中获取上传的文件
        guard let file = try? req.content.get(File.self, at: "file") else {
            throw Abort(.badRequest, reason: "未能获取上传的文件")
        }
        
        // 生成临时文件路径
        let fileName = UUID().uuidString + "_" + file.filename
        let filePath = app.directory.publicDirectory + fileName

        do {
            try FileManager.default.createDirectory(atPath: app.directory.publicDirectory, withIntermediateDirectories: true)
        } catch {
            throw Abort(.badRequest, reason: "Unable to create directory: \(error)")
        }
        
        // 保存上传的文件
        try await req.fileio.writeFile(file.data, at: filePath)
        
        // 处理图片
        let result = try processImage(url: URL(fileURLWithPath: filePath))
        
        // 删除临时文件
        try FileManager.default.removeItem(atPath: filePath)
        
        // 创建响应
        let jsonString = result.compact.json
        
        return Response(
            status: .ok,
            headers: ["Content-Type": "application/json"],
            body: .init(string: jsonString)
        )
    }

    app.post("ocr2csv") { req async throws -> Response in
        // 从请求中获取上传的文件
        guard let file = try? req.content.get(File.self, at: "file") else {
            throw Abort(.badRequest, reason: "未能获取上传的文件")
        }
        
        // 生成临时文件路径
        let fileName = UUID().uuidString + "_" + file.filename
        let filePath = app.directory.publicDirectory + fileName
        
        // 保存上传的文件
        try await req.fileio.writeFile(file.data, at: filePath)
        
        // 处理图片
        let result = try processImage(url: URL(fileURLWithPath: filePath))
        
        // 删除临时文件
        try FileManager.default.removeItem(atPath: filePath)
        
        // 创建响应
        let csvString = result.compact.csv
        
        return Response(
            status: .ok,
            headers: ["Content-Type": "text/csv"],
            body: .init(string: csvString)
        )
    }
}

struct Input: Content {
    var file: File
}

func processImage(url: URL) throws -> BillOCRResult {
    guard let img = NSImage(contentsOf: url) else {
        throw Abort(.badRequest, reason: "Unable to load image: \(url)")
    }
    print("Image loaded: \(url)")

    guard let cgImage = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        throw Abort(.badRequest, reason: "Unable to create CGImage")
    }

    let requestHandler = VNImageRequestHandler(cgImage: cgImage)
    
    let imageWidth = Int(cgImage.width)
    let imageHeight = Int(cgImage.height)
    
    let request = VNRecognizeTextRequest()
    request.recognitionLanguages = ["zh-Hans", "zh-Hant", "en_US"]
    
    do {
        try requestHandler.perform([request])
    } catch {
        throw Abort(.badRequest, reason: "Unable to perform request: \(error)")
    }
    
    guard let observations = request.results else {
        throw Abort(.badRequest, reason: "Unable to get recognition results")
    }
    
    let ocrWords = observations.compactMap { observation -> BillOCRResult.Words? in
        guard let candidate = observation.topCandidates(1).first else {
            return nil
        }
        
        let words = candidate.string
        let boundingBox = try? candidate.boundingBox(for: words.startIndex..<words.endIndex)
        let rect = VNImageRectForNormalizedRect(boundingBox?.boundingBox ?? .zero, Int(CGFloat(imageWidth)), Int(CGFloat(imageHeight)))
        
        return BillOCRResult.Words(
            words: words,
            location: .init(
                top: Int(rect.origin.y),
                left: Int(rect.origin.x),
                width: Int(rect.size.width),
                height: Int(rect.size.height)
            )
        )
    }
    
    let ocrResultSorted = ocrWords.sorted { $0.location.top > $1.location.top }
    return BillOCRResult(words: ocrResultSorted, count: ocrResultSorted.count)
}
