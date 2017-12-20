///// Copyright (c) 2017 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
// 1
import Alamofire

// 2
public enum ImaggaRouter: URLRequestConvertible {
  
  // 3
  static let baseURLPath = "http://api.imagga.com/v1"
  static let authenticationToken = "Basic xxx"
  
  // 4
  case content
  case tags(String)
  case colors(String)
  
  // 5
  var method: HTTPMethod {
    switch self {
    case .content:
      return .post
    case .tags, .colors:
      return .get
    }
  }
  
  // 6
  var path: String {
    switch self {
    case .content:
      return "/content"
    case .tags:
      return "/tagging"
    case .colors:
      return "/colors"
    }
  }
  
  // 7
  public func asURLRequest() throws -> URLRequest {
    
    // 8
    let parameter: [String: Any] = {
      switch self {
      case .tags(let contentID):
        return ["content": contentID]
      case .colors(let contentID):
        return ["content": contentID, "extract_object_colors": 0]
      default:
        return [:]
      }
    }()
    
    // 9
    let url = try ImaggaRouter.baseURLPath.asURL()
    
    // 10
    var request = URLRequest(url: url.appendingPathComponent(path))
    request.httpMethod = method.rawValue
    request.setValue(ImaggaRouter.authenticationToken, forHTTPHeaderField: "Authorization")
    request.timeoutInterval = TimeInterval(10 * 1000)
    
    // 11
    return try URLEncoding.default.encode(request, with: parameter)
  }
  
}
