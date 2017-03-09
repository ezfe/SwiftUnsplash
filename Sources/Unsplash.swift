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
    
    @discardableResult
    func getUser(name username: String, handler: @escaping (JSON?) -> Void) -> Bool {
        guard let encodedUsername = username.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed), let url = URL(string: "/users/\(encodedUsername)", relativeTo: baseURL) else {
            print("URL creation failed")
            return false
        }

        json(for: url) { (json, error) in
            if let json = json {
                handler(json)
            } else {
                print("Failure fetching user")
            }
        }
        
        return true
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
