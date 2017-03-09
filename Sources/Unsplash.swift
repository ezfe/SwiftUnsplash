//
//  Unsplash.swift
//  WallpaperFetcher
//
//  Created by Ezekiel Elin on 3/9/17.
//
//

import Cocoa
import SwiftyJSON

public class Unsplash {
    let appID: String
    
    let baseURL = URL(string: "https://api.unsplash.com/")!
    
    public init(appID: String) {
        self.appID = appID
    }
    
    func request(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue("Client-ID \(appID)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func session(for url: URL, handler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let session = URLSession.shared.dataTask(with: request(for: url), completionHandler: handler)
        session.resume()
    }
    
    func json(for url: URL, handler: @escaping (JSON?, Error?) -> Void) {
        session(for: url) { (data, _, error) in
            if let data = data {
                handler(JSON(data), error)
            } else {
                handler(nil, error)
            }
        }
    }
    
    public func getUser(name username: String, handler: @escaping (JSON?) -> Void) {
        guard let encodedUsername = username.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed), let url = URL(string: "/users/\(encodedUsername)", relativeTo: baseURL) else {
            handler(nil)
            return
        }

        json(for: url) { (json, _) in
            handler(json)
        }
    }
    
    public func randomPhotoManifest(handler: @escaping (JSON?) -> Void) {
        if let url = URL(string: "/photos/random", relativeTo: baseURL) {
            json(for: url) { (json, _) in
                handler(json)
            }
        } else {
            handler(nil)
            return
        }
    }
    
    public func photoManifest(id: String, handler: @escaping (JSON?) -> Void) {
        guard let encodedID = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed), let url = URL(string: "/photos/\(encodedID)", relativeTo: baseURL) else {
            handler(nil)
            return
        }
        
        json(for: url) { (json, _) in
            handler(json)
        }
    }
    
    public func photo(manifest: JSON, handler: @escaping (NSImage?) -> Void) {
        if let imageURL = URL(string: manifest["urls"]["full"].stringValue) {
            self.session(for: imageURL) { (data, _, _) in
                if let data = data {
                    handler(NSImage(data: data))
                } else {
                    handler(nil)
                }
            }
        }
    }
    
    public func photo(id: String, handler: @escaping (NSImage?) -> Void) {
        photoManifest(id: id) { (manifest) in
            guard let manifest = manifest else {
                handler(nil)
                return
            }
            
            self.photo(manifest: manifest, handler: handler)
        }
    }
    
    public func randomPhoto(handler: @escaping  (NSImage?) -> Void) {
        randomPhotoManifest { (manifest) in
            guard let manifest = manifest else {
                handler(nil)
                return
            }
            
            self.photo(manifest: manifest, handler: handler)
        }
    }
}
