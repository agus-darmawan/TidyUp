//
//  ImageStorageService.swift
//  TidyUp
//
//  Stores photos (journal, wardrobe, receipts/item photos for reimbursements)
//  as JPEG files under Application Support, keyed by UUID filename.
//

import Foundation
import UIKit

final class ImageStorageService {
    private let fileManager = FileManager.default

    private lazy var imagesDirectory: URL = {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let directory = appSupport.appendingPathComponent("Images", isDirectory: true)
        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }()

    @discardableResult
    func saveImage(_ image: UIImage, compressionQuality: CGFloat = 0.8) throws -> String {
        let filename = "\(UUID().uuidString).jpg"
        let url = imagesDirectory.appendingPathComponent(filename)
        guard let data = image.jpegData(compressionQuality: compressionQuality) else {
            throw ImageStorageError.encodingFailed
        }
        try data.write(to: url, options: .atomic)
        return filename
    }

    func loadImage(filename: String) -> UIImage? {
        let url = imagesDirectory.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    /// Raw bytes for a stored image — used when embedding photos into a backup export.
    func loadRawData(filename: String) -> Data? {
        try? Data(contentsOf: imagesDirectory.appendingPathComponent(filename))
    }

    /// Restores an image from a backup at its exact original filename, so
    /// every model's stored `photoFilename` reference still resolves correctly.
    func restoreRawData(_ data: Data, filename: String) {
        try? data.write(to: imagesDirectory.appendingPathComponent(filename), options: .atomic)
    }

    func deleteImage(filename: String) {
        try? fileManager.removeItem(at: imagesDirectory.appendingPathComponent(filename))
    }

    enum ImageStorageError: Error { case encodingFailed }
}
