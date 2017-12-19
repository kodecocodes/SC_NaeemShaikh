# Screencast Metadata

## Screencast Title

Alamofire: Getting Started

## Screencast Description

Uploading files using Alamofire, a very popular Swift-based HTTP networking library for iOS and Mac OS.

## Language, Editor and Platform versions used in this screencast:

* **Language:** [Swift 4]
* **Platform:** [iOS 11]
* **Editor**: [Xcode 9]

## Introduction

"Hey what's up everybody, this is Naeem. In today's screencast, I'm going to show how to upload files with a very popular networking library called Alamofire."

Alamofire provides an elegant interface on top of Apple’s Foundation networking stack that simplifies a number of common networking tasks.a

Alamofire’s elegance comes from the fact it was written from the ground up in Swift and does not inherit anything from its Objective-C counterpart, AFNetworking.

Before we get started, I want to give a big shout out to Aaron Douglas. Aaron wrote a tutorial on Alamofire which is the basis of this screencast. Thanks Aaron.

[Show some LAN cable or wire]
Uploading files using Alamofire is super easy, so lets blow some wire with Alamofire!

## Demo 1

First of all, we need to import Alamofire into our project. so lets do that.
```
// 1
import Alamofire
```

Next, we will create a function called `upload` to upload files, which takes UIImage is input

```
// 2
func upload(image: UIImage,
            progressCompletion: (_ percent: Float) -> Void,
            completion: (_ result: Bool) -> Void) {
}
```

## Interlude

For this screencast, we are using a third-party image upload service called `Imagga`.

You’ll need to create a free developer account with `Imagga`, to get authorization header, which needs to be included in each HTTP request so that only people with an account can use their services.

Go to: `https://imagga.com/auth/signup/hacker`, fill out the form. And list down `Authorization` token to somewhere.

## Demo 2

Now, The first step in uploading an image to `Imagga` is to get the image into the correct format for use with the API. So we need to convert UIImage instance into a JPEG Data instance.

```
// 3
guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {
  print("Could not get JPEG representation of UIImage")
  return
}
```

Next, we need to call `upload` function from `UIImagePickerController`s delegate method.

```
upload(image: <#T##UIImage#>, progressCompletion: <#T##(Float) -> Void#>, completion: <#T##(Bool) -> Void#>)
```


```
upload(
      image: image,
      progressCompletion: { [weak self] percent in
        guard let strongSelf = self else {
          return
        }
      },
      completion: { [weak self] result in
        guard let strongSelf = self else {
          return
        }
    })
```

## Interlude

## Closing
