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
    
    func photoManifest(id: String, handler: @escaping (JSON?) -> Void) {
        guard let encodedID = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed), let url = URL(string: "/photos/\(encodedID)", relativeTo: baseURL) else {
            handler(nil)
            return
        }
        
        json(for: url) { (json, _) in
            handler(json)
        }
    }
    
    func photo(id: String, handler: @escaping (NSImage?) -> Void) {
        photoManifest(id: id) { (manifest) in
            guard let manifest = manifest else {
                handler(nil)
                return
            }
            
            if let imageURL = URL(string: manifest["urls"]["full"].stringValue) {
                self.session(for: imageURL) { (data, _, error) in
                    if let data = data {
                        handler(NSImage(data: data))
                    } else {
                        handler(nil)
                    }
                }
            }
        }
    }
    
    public func randomPhoto(imageHandler: @escaping (NSImage) -> Void) {
        let session = URLSession.shared.dataTask(with: URL(string: "/photos/random?client_id=\(appID)", relativeTo: baseURL)!) { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                if let obj = json as? [String: AnyObject], let urls = obj["urls"] as? [String: AnyObject], let full = urls["full"] as? String {
                    guard let url = URL(string: full) else {
                        print("URL couldn't be made")
                        return
                    }
                    
                    imageHandler(NSImage(contentsOf: url)!)
                } else {
                    print(json)
                }
            } catch {
                print("Uh")
            }
        }

        session.resume()
    }

}
