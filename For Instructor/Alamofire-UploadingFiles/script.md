# Screencast Metadata

## Screencast Title

**Alamofire**: Uploading Files

## Screencast Description

Uploading files using **Alamofire**, a very popular Swift-based HTTP networking library for iOS, macOS, watchOS and tvOS.

## Language, Editor and Platform versions used in this screencast:

* **Language:** [Swift 4]
* **Platform:** [iOS 11]
* **Editor**: [Xcode 9.2]

## Introduction

Hey what's up everybody, this is Naeem. In today's screencast, I'm going to show you how to upload a file using **Alamofire**.

**Alamofire** is a popular networking library written up in Swift for,
- iOS,
- macOS,
- watchOS,
- and tvOS.

It is created by the **Alamofire Software Foundation**.

There's a lot to like about **Alamofire**. It provides an elegant interface on top of Apple’s Foundation networking stack that simplifies a number of common networking tasks.

It has all the features you'd expect in a networking library including **Parameter encoding**, **Response Serialization**, **Authentication**, and many more.

Its elegance comes from the fact that, it is written up in Swift and does not inherit anything from its Objective-C counterpart, **AFNetworking**.

And at the time of making this screencast, **Alamofire** appears to be the most commonly used Swift-based networking library.

Soooo, I'm very excited to show you today!

Before we get started, I wanna give a big thanks to **Aaron Douglas**. Aaron wrote a tutorial on **Alamofire** which is the basis of this screencast. Thanks Aaron.

[Show some LAN cable or wire]

Uploading files using **Alamofire** is super easy, so lets blow up some wire with **Alamofire**!

## Demo 1

First of all, we need to import **Alamofire** into our project. so lets do that.
There are 4 types of installation options available to integrate `Alamofire`, among them we have used `CocoaPods`.

```
// 1
import Alamofire
```

Next, we will create a function called `upload` to upload files, which takes `UIImage` as input parameter and returns file uploading progress with completion block.

```
// 2
func upload(image: UIImage,
            progressCompletion: @escaping (_ percent: Float) -> Void,
            completion: @escaping (_ result: Bool) -> Void) {
}
```

## Interlude 1

For this screencast, we are using a third-party image uploading service called, **Imagga**.

You’ll need to create a free developer account with **Imagga**, to get authorization token, which needs to be included in each and every HTTP request, so that only people with an account can use their services.

[Show **Imagga**'s signup and dashboard page]

Go to: `https://imagga.com/auth/signup/hacker`, fill out the form, and list down `Authorization` token to somewhere, which we use later.

We are using **Imagga**’s `content` endpoint API to upload the photos, there are other API endpoints also like, `tagging` for the image recognition and `colors` for color identification.

You can read all about the **Imagga** APIs at `http://docs.imagga.com`.

## Demo 2

Now, The first step in uploading an image to **Imagga** is to get the image into the correct format for use with the API. So we need to convert `UIImage` instance into a `JPEG` Data instance.

```
// 3
guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {
  print("Could not get JPEG representation of UIImage")
  return
}
```

Next, we need to call `upload` function from `UIImagePickerController`'s delegate method.

```
// 4
upload(image: UIImage, progressCompletion: (Float) -> Void, completion: (Bool) -> Void)
```

Everything with **Alamofire** is asynchronous, which means you’ll update the UI in an asynchronous manner:

1. While the file uploads, we call the progress handler with an updated percent. This updates the progress indicator of the progress bar.

```
// 5
progressCompletion: { [weak self] percent in
  guard let strongSelf = self else {
    return
  }

  strongSelf.progressView.setProgress(percent, animated: true)
},
```

2. The completion handler executes when the upload finishes. This sets the state of the controls back to their original state.

```
// 6
completion: { [weak self] result in
  guard let strongSelf = self else {
    return
  }

  // 7
  strongSelf.takePictureButton.isHidden = false
  strongSelf.progressView.isHidden = true
  strongSelf.activityIndicatorView.stopAnimating()
  strongSelf.imageView.image = nil
}
```

Next, go back to `upload(image:progressCompletion:completion:)` function and add **Alamofire** upload function call, set the **Imagga** API endpoint with `Authorization` header. Make sure to replace `Basic xxx` with the actual authorization header taken from the **Imagga** dashboard.
Here we convert the `JPEG` data blob (imageData) into a `MIME` multipart request to send to the **Imagga** content endpoint.

```
// 8
Alamofire.upload(
  multipartFormData: { multipartFormData in
    multipartFormData.append(imageData,
                             withName: "imageFile",
                             fileName: "image.jpg",
                             mimeType: "image/jpeg")
},
  to: "http://api.imagga.com/v1/content",
  headers: ["Authorization": "Basic xxx"],
  encodingCompletion: { encodingResult in
})
```

Next, we call the **Alamofire** upload function and passes in a small calculation to update the progress bar as the file uploads, It then validates the response has a status code in the default acceptable range (between 200 and 299).

```
// 9
switch encodingResult {
case .success(let upload, _, _):
  upload.uploadProgress { progress in
    progressCompletion(Float(progress.fractionCompleted))
  }
  upload.validate()
  upload.responseJSON { response in
  }
case .failure(let encodingError):
  print(encodingError)
}
```

## Interlude 2

Prior to **Alamofire 4**, it was not guaranteed that, progress callbacks were called on the main queue. Starting with **Alamofire 4** the new progress API callback is always called on the main queue.

You can check more details on **Alamofire 4** migration guide at given link:
```
https://github.com/Alamofire/Alamofire/blob/master/Documentation/Alamofire%204.0%20Migration%20Guide.md
```

## Demo 3

Now, it's time to get our hands dirty with some `JSON` parsing.

1. Check if the response was successful; if not, print the error and call the completion handler.
```
// 10
guard response.result.isSuccess else{
  print("Error while uploading file: \(String(describing: response.result.error))")
  completion(false)
  return
}
```

2. Check each portion of the response, verifying the expected type is the actual type received. Retrieve the `firstFileID` from the response. If `firstFileID` cannot be resolved, print out an error message and call the completion handler.

```
// 11
guard let responseJSON = response.result.value as? [String: Any],
  let uploadedFiles = responseJSON["uploaded"] as? [Any],
  let firstFile = uploadedFiles.first as? [String: Any],
  let firstFileID = firstFile["id"] as? String else {
    print("Invalid information received from service")
    completion(false)
    return
}
```

3. Print the uploaded `fileID` and call the completion handler to update the UI.

```
// 12
print("Content uploaded with ID: \(firstFileID)")
completion(true)
```

## Interlude 3
Every response has a `Result` enum with a value and type.

Using automatic validation, the result is considered a success when it returns a valid `HTTP Code` between `200 and 299`.

And the Content Type is of a valid type specified in the `Accept HTTP` header field.

## Demo 4
You can perform manual validation by adding `.validate` options like this:

```
Alamofire.request("https://httpbin.org/get", parameters: ["foo": "bar"])
  .validate(statusCode: 200..<300)
  .validate(contentType: ["application/json"])
  .response { response in
    // response validation code
}
```

Now, build and run your project; select an image and watch the progress bar change as the file uploads.
You should see a note with uploaded `fileID` in your console when the upload completes:

```
Content uploaded with ID: 6cda50de4521c42675cac5d269b2e87d
```

Congratulations, you've successfully uploaded a file over the Interwebs!

## Closing

Allright, that's everything I'd like to cover in this screencast.

At this point, you should have understanding of,
- how to upload files using **Alamofire**,
- handling **Alamofire**'s async states for UI updates,  
- some basic JSON parsing,
- and response validation.

There's a lot more to **Alamofire** - including,
- **Parameter encoding**,
- **Authentication**,
- and **Routing Requests**.

Please let me know if you like this screencast and if you'd like to see more on Alamofire.

Thanks for watching - and I look forward to see your some wire blowing up with **Alamofire**!.
