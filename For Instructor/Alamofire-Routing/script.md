# Screencast Metadata

## Screencast Title

**Alamofire**: Routing Requests

## Screencast Description

Refactoring code duplication and provide centralized configuration for **Alamofire** network calls.

## Language, Editor and Platform versions used in this screencast:

* **Language:** [Swift 4]
* **Platform:** [iOS 11]
* **Editor**: [Xcode 9.2]

## Introduction

"Hey what's up everybody, this is Naeem. In today's screencast, I'm going to show you how to refactor code duplication and provide centralized configuration for **Alamofire** network calls."

**Alamofire** is a very popular Swift-based HTTP networking library for iOS, macOS, watchOS and tvOS, it is created by **Alamofire Software Foundation**.

Probably you have created `APIManager` or `NetworkModel` of your apps using **Alamofire**, which ends up in a mess on every new version of APIs.

As apps grow in size, it's important to adopt common patterns as you build out your network stack. An important part of that design is how to route your requests. The **Alamofire** `URLConvertible` and `URLRequestConvertible` protocols along with the Router design pattern are here to help.

We are going to use `URLRequestConvertible` protocol in this screencast for refactoring networking calls.

Before we get started, I want to give a big shout out to Aaron Douglas. Aaron wrote a tutorial on Alamofire which is the basis of this screencast. Thanks Aaron.

Refactoring repeated code in **Alamofire** is super easy, so let's dive in.

## Demo 1

In our screencast demo we have 3 **Alamofire** networking function with hardcoded URL, API endpoints with common `Authorization` token.

Upload function:
```
Alamofire.upload(
  multipartFormData: { multipartFormData in
    multipartFormData.append(imageData,
                             withName: "imagefile",
                             fileName: "image.jpg",
                             mimeType: "image/jpeg")
},
  to: "http://api.imagga.com/v1/content",
  headers: ["Authorization": "Basic xxx"],
  encodingCompletion: { encodingResult in
})
```

Download Tags function:
```
Alamofire.request(
  "http://api.imagga.com/v1/tagging",
  parameters: ["content": contentID],
  headers: ["Authorization": "Basic xxx"]
  )
```

Download Colors function:
```
Alamofire.request(
    "http://api.imagga.com/v1/colors",
    parameters: ["content": contentID],
    headers: ["Authorization": "Basic xxx"]
    )
```

If any URL among this functions changes, you'd have to update the URL in each of the three methods. Similarly, if your `Authorization` token changed you'd be updating it all over the place.

**Alamofire** provides a simple method to eliminate this code duplication and provide centralized configuration. The technique involves creating a struct conforming to the `URLRequestConvertible` protocol and updating your networking calls.

First of all, create a new Swift file by clicking `File\New\File...` and selecting `Swift file` under `iOS`. Click Next, name the file `ImaggaRouter.swift`, select the Group `Services` with the yellow folder icon and click `Create`.

Next, import **Alamofire** to `ImaggaRouter.swift` file.
```
// 1
import Alamofire
```

Create a public enum conforms to `URLRequestConvertible` protocol to construct URL requests.
```
// 2
public enum ImaggaRouter: URLRequestConvertible {

}
```

Now, define `baseURLPath`, and `authenticationToken` which is common in all networking requests.
```
// 3
static let baseURLPath = "http://api.imagga.com/v1"
static let authenticationToken = "Basic xxx"
```

Next, Write down cases of URL request endpoints.
```
// 4
case content
case tags(String)
case colors(String)
```

Now, set `HTTPMethod` of each URL request endpoints.
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

Next, define endpoint of each URL request.
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

Now, to conforming `URLRequestConvertible`, we need to add `asURLRequest()` function to our public enum, lets do that.
```
// 7
  public func asURLRequest() throws -> URLRequest {
    <#code#>
  }
```

Next, Create a parameter `Dictionary` to set API parameters.
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

Now, Define url as `baseURLPath`.
```
// 9
let url = try ImaggaRouter.baseURLPath.asURL()
```

Next, declare a request variable of `URLRequest` type, set it's `httpMethod`, `Authorization` header and request timeout value.
```
// 10
var request = URLRequest(url: url.appendingPathComponent(path))
request.httpMethod = method.rawValue
request.setValue(ImaggaRouter.authenticationToken, forHTTPHeaderField: "Authorization")
request.timeoutInterval = TimeInterval(10 * 1000)
```

Than, return `URLEncoding` with the request and parameter we have defined easier.
```
// 11
return try URLEncoding.default.encode(request, with: parameter)
```

Replace `Basic xxx` with your actual `Authorization` header. This router helps create mutable instances of `URLRequest` by providing it one of the three cases: `.content`, `.tags(String)`, or `.colors(String)`. Now all your boilerplate code is in single place, should you ever need to update it.

Now it's time replace boilerplate code with our newly created enum.

Go back to, Upload function and replace following code
```
  to: "http://api.imagga.com/v1/content",
  headers: ["Authorization": "Basic xxx"],
```

with our `ImaggaRouter` enum.
```
// 12
  with: ImaggaRouter.content,
```

Next replace the call for `Alamofire.request` in,
```
Alamofire.request(
  "http://api.imagga.com/v1/tagging",
  parameters: ["content": contentID],
  headers: ["Authorization": "Basic xxx"]
)
```

`downloadTags(contentID:completion:)` function with:
```
 // 13
 Alamofire.request(ImaggaRouter.tags(contentID))
```

Finally, update the call to `Alamofire.request` in,
```
Alamofire.request(
  "http://api.imagga.com/v1/colors",
  parameters: ["content": contentID],
  headers: ["Authorization": "Basic xxx"]
)
```

`downloadColors(contentID:completion:)` function with:
```
// 14
Alamofire.request(ImaggaRouter.colors(contentID))
```

Build and run for the final time; everything should function just as before, which means you've refactored everything without breaking your app. Awesome job!

## Interlude

If you want even more cleaner type safe routing in your networking stack apart from what **Alamofire** provides, than check out **Moya** and **AlamofireURLRequestConfigurable** libraries.

**Moya** is built to create a network abstraction layer that sufficiently encapsulates actually calling **Alamofire** directly.
You can find all about **Moya** at their GitHub repository: ``` https://github.com/Moya/Moya ```

**AlamofireURLRequestConfigurable** is a replacement for **Alamofire**'s `URLRequestConvertible` protocol.
You can find all about **AlamofireURLRequestConfigurable** at their GitHub repository: ``` https://github.com/gmarm/AlamofireURLRequestConfigurable ```

Maybe we'll cover up these in more details on our future screencasts, so stay tuned to: ``` https://www.raywenderlich.com ```

## Closing

Allright, that's everything I'd like to cover in this screencast.

At this point, you should understand how to refactor boilerplate code without breaking your app, create enum conforming to `URLRequestConvertible` protocol, ensuring consistency of requested endpoints, abstract away server-side inconsistencies and provide type-safe routing.

There's a lot more to **Alamofire** - including **chainable request/response methods**, **Parameter encoding**, **Authentication**, and more which I'll be covering in other screencasts, so be sure to keep an eye out for those.

Thanks for watching!
