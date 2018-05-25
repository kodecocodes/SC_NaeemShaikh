# Screencast Metadata

## Screencast Title

**Alamofire**: Routing Requests

## Screencast Description

The screencast shows how to refactor your Alamofire code to avoid code duplication and provide a centralized configuration for network calls.

## Language, Editor and Platform versions used in this screencast:

* **Language:** [Swift 4]
* **Platform:** [iOS 11]
* **Editor**: [Xcode 9.2]

## Introduction

Hey what's up everybody, this is Brian and in today's screencast, I'm going to show you how to avoid code duplication and provide centralized configuration for **Alamofire** network calls. If you've used Alamofire, you've probably created an `APIManager` or `NetworkModel` in your apps which ends up in a mess with every new API version

Let's have a look on the examples of **Alamofire** networking stack which has code duplication, that ends up in a mess on every API changes.

For instance, you may have a variety of url endpoints. If any URL changes, you'd have to update any of the alamofire calls. Thankfully **Alamofire** provides a simple method to eliminate this code duplication and provide centralized configuration. The technique involves creating a struct conforming to the `URLRequestConvertible` protocol and updating your networking calls.

Now before I get started, I wanna give a big thanks to **Aaron Douglas**. Aaron wrote a tutorial on **Alamofire** which is the basis of this screencast. Thanks Aaron. I'd also like to thank Na-eem Shay-key who produced the materials for this screencast. When you have a moment, give them both a follow on Twitter. 

Let's dive in.

## Demo 1

So here I have a project that uses individual alamofire calls used throughout it. When I build in run, I can upload an image to the Imagga service which anylze my image. I want to update my app so I can centralize my calls using the URLRequestConvertible protocol. Opening up ViewController.swift, you'll see that I make my request using Alamofire. The authorizationKey variable is just a string with my own key. If you want to follow along, make sure to open the Constants.swift file and replace the contents of the authorization key variable.

I'll start by creating a new Swift file called  `ImaggaRouter.swift`. Next, I import the **Alamofire** framework. 

```
// 1
import Alamofire
```

I create a public enum conforms to `URLRequestConvertible` protocol to construct URL requests.
```
// 2
public enum ImaggaRouter: URLRequestConvertible {

}
```

Now, I define `baseURLPath`, and the `authenticationToken` which is common in all networking requests.
```
// 3
static let baseURLPath = "http://api.imagga.com/v1"
static let authenticationToken = "Basic xxx"
```

Next, I write down cases of URL request endpoints.
```
// 4
case content
case tags(String)
case colors(String)
```

Then I set `HTTPMethod` of each URL request endpoints.
```
// 5
  var method: HTTPMethod {
    switch self {
    case .content:
      return .post
    case .tags, .colors:
      return .get
    }
  }
```

Afterwhich I define endpoint of each URL request.
```
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
```

Then, I create a parameter `Dictionary` to set API parameters.
```
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
```

To conform to the `URLRequestConvertible`, I need to add `asURLRequest()` function to my public enum:
```
// 7
  public func asURLRequest() throws -> URLRequest {
    <#code#>
  }
```

Now, I define a url as `baseURLPath`.
```
// 9
let url = try ImaggaRouter.baseURLPath.asURL()
```

Then I declare a request variable of `URLRequest` type, set it's `httpMethod`, `Authorization` header and request timeout value.
```
// 10
var request = URLRequest(url: url.appendingPathComponent(path))
request.httpMethod = method.rawValue
request.setValue(ImaggaRouter.authenticationToken, forHTTPHeaderField: "Authorization")
request.timeoutInterval = TimeInterval(10 * 1000)
```

Than, I return `URLEncoding` with the request and parameter we have defined easier.
```
// 11
return try URLEncoding.default.encode(request, with: parameter)
```

I Replace `Basic xxx` with my actual `Authorization` header. This router helps create mutable instances of `URLRequest` by providing it one of the three cases: `.content`, `.tags`, or `.colors`. Now all my boilerplate code is in single place, should I ever need to update it.

At this point, I have code ready to be used. To do this, I open ViewController.swift and I alter the upload function to use the ImaggaRouter enum.

[[Replace]]
```
  to: "http://api.imagga.com/v1/content",
  headers: ["Authorization": "Basic xxx"],
```

[[With]]
```
// 12
  with: ImaggaRouter.content,
```

Next I replace the call for `Alamofire.request` in the downloadTags function to use the enum. 

[[Replace]]
```
Alamofire.request(
  "http://api.imagga.com/v1/tagging",
  parameters: ["content": contentID],
  headers: ["Authorization": "Basic xxx"]
)
```
[[With]]
```
 // 13
 Alamofire.request(ImaggaRouter.tags(contentID))
```

Finally, I update the call in downloadColors to also use my enum:

[[Replace]]
```
Alamofire.request(
  "http://api.imagga.com/v1/colors",
  parameters: ["content": contentID],
  headers: ["Authorization": "Basic xxx"]
)
```
[[With]]
```
// 14
Alamofire.request(ImaggaRouter.colors(contentID))
```

Now I'll build and run; everything should functions just as before, which means I get the same flexibility with future adaptiblity.

## Conclusion

If you want even more cleaner type safe routing in your networking stack apart from what **Alamofire** provides, than check out Moya and **AlamofireURLRequestConfigurable** libraries. **Moya** is built to create a network abstraction layer that sufficiently encapsulates actually calling **Alamofire** directly.

**AlamofireURLRequestConfigurable** is a replacement for **Alamofire**'s `URLRequestConvertible` protocol that provides cleaner and flexible type safe routing. For more screencasts and tutorials about Alamofire and iOS develpment in particuliar, keep coming back to raywenderlich.com. 
Okay, I'm out.

For more tutorials and screencasts about alamofire, keep coming back to raywenderlich.com. 

