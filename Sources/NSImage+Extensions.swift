//
//  NSImage+Extensions.swift
//  WallpaperFetcher
//
//  Created by Ezekiel Elin on 3/9/17.
//
//

import Cocoa

/*
 * Based off code example from
 * http://stackoverflow.com/a/39677995/2059595
 */
public extension NSImage {
    public func save(to url: URL, as: NSBitmapImageFileType = NSBitmapImageFileType.PNG) throws {
        enum SaveError: Error {
            case tiffFailed
            case representationFailed
        }
        
        guard let tiffRepresentation = self.tiffRepresentation else {
            throw SaveError.tiffFailed
        }
        
        let imageRep = NSBitmapImageRep(data: tiffRepresentation)
        guard let imageData = imageRep?.representation(using: .PNG, properties: [:]) else {
            throw SaveError.representationFailed
        }
        try imageData.write(to: url)
    }
}
