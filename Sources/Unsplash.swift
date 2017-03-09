//
//  Unsplash.swift
//  WallpaperFetcher
//
//  Created by Ezekiel Elin on 3/9/17.
//
//

import Cocoa

public class Unsplash {
    fileprivate let appID: String
    
    fileprivate let baseURL = URL(string: "https://api.unsplash.com/")!
    
    public init(appID: String) {
        self.appID = appID
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
