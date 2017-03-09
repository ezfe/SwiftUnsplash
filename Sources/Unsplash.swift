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
    
    public func getUser(username: String, error errorHandler: @escaping (() -> Void) = {() in}, success: @escaping (JSON) -> Void) {
        guard let encodedUsername = username.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed), let url = URL(string: "/users/\(encodedUsername)", relativeTo: baseURL) else {
            print("URL creation failed")
            errorHandler()
            return
        }
        let request = self.request(for: url)
        let session = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Unable to make HTTPURLResponse object")
                errorHandler()
                return
            }
            
            if httpResponse.statusCode != 200 {
                print("Status code: \(httpResponse)")
                errorHandler()
                return
            }
            
            guard let data = data else {
                print(error?.localizedDescription ?? "Unknown Network Error")
                errorHandler()
                return
            }
            
            let json = JSON(data: data)
            success(json)
        }
        session.resume()
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
