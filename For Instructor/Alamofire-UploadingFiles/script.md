# Screencast Metadata

## Screencast Title

**Alamofire**: Uploading Files

## Screencast Description

**Alamofire** is a popular Swift-based HTTP networking library and in the screencast you'll learn how to use it to upload files.

## Language, Editor and Platform versions used in this screencast:

* **Language:** [Swift 4]
* **Platform:** [iOS 11]
* **Editor**: [Xcode 9.2]

## Introduction

Hey what's up everybody, this is Brian and in today's screencast, I'm going to show you how to upload a file using **Alamofire**. Curious about Alamofire? This is third party framework that provides an elegant interface on top of Apple’s Foundation networking stack. Doing this, it simplifies a number of common networking tasks such as parameter encoding, response serialization, authentication, and more.

Its elegance comes from the fact that, it is written up in Swift from the very beginning and does not inherit anything from its Objective-C counterpart, **AFNetworking**. And at the time of making this screencast, **Alamofire** appears to be the most commonly used Swift-based networking library.

Before I get started, I wanna give a big thanks to **Aaron Douglas**. Aaron wrote a tutorial on **Alamofire** which is the basis of this screencast. Thanks Aaron. I also would like to thank Na-eem Shay-key who produced the materials for this screencast. When you have a moment, give them both a follow on Twitter. 

Let's dive in.

## Demo 1

Getting started, I have a project that I want to upload files to a third party image service, Imagga. I've already created a free account and have the necessary credentials. The service requires that I provide each request with an authorization token. I'm storing this token as a string contstant called Authorization token which I'll send to the service when uploading. 

To get started, I open ViewController.swift and import the Alamofire framework which I've already installed using cocoapods.  

```
// 1
import Alamofire
```

Next, I will create a function called `upload` to upload files, which takes `UIImage` as an input parameter as well as a progress completion and regular completion closure. The progress completion is used to update a progress bar and the completion handler will be called when the upload concludes.

```
// 2
func upload(image: UIImage,
            progressCompletion: @escaping (_ percent: Float) -> Void,
            completion: @escaping (_ result: Bool) -> Void) {
}
```


Now, The first step in uploading an image tis to get the image into the correct format for use with the API so I need to convert `UIImage` instance into a `JPEG` Data instance. To do this, I call UIImageJPEGRepresentation. 

```
// 3
guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {
  print("Could not get JPEG representation of UIImage")
  return
}
```

Next, I need to call `upload` function from `UIImagePickerController`'s delegate didFinishPickingMediaWithInfo method.

```
// 4
upload(image: UIImage, progressCompletion: (Float) -> Void, completion: (Bool) -> Void)
```

Everything with **Alamofire** is asynchronous, which means I'll need to update the UI in an asynchronous manner.

While the file uploads,  I call the progress handler with an updated percent. This updates the progress indicator of the progress bar.

```
// 5
progressCompletion: { [weak self] percent in
  guard let strongSelf = self else {
    return
  }

  strongSelf.progressView.setProgress(percent, animated: true)
},
```

The completion handler executes when the upload finishes. This sets the state of the controls back to their original state.

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
And that's it. Everything is in place. The only thing left to call is use Alamofire. I go back to the `upload()` function and add an **Alamofire** upload function call. Here I convert the `JPEG` imageData into a `MIME` multipart request to send to the content endpoint. I set the  API endpoint with `Authorization` header. I'm using my own token variable but if you were connecting to your own account, you would put your authoziation token here. 

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

Then, I pass in a small calculation to update the progress bar as the file uploads. After which, I call validate. This method makes sure that the response has a status code in the default accetable range. Next I have provide a closure for the responseJSON. More on this in a moment. And finally, I provide a failure case that simply prints out the error.

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

## Interlude

Prior to **Alamofire 4**, it was not guaranteed that, progress callbacks were called on the main queue. Starting with **Alamofire 4** the new progress API callback is always called on the main queue.

You can check more details on **Alamofire 4** migration guide at given link:

Now, for the JSON parsing. We'll be using SwiftyJSON which is included with the Alamfire framework. If you want to using Swift 4's native JSON parsing, check out the CodableAlamofire extension over at github.

## Demo

Back in our ViewController.swift, I want to write some code to validate my returned JSON. I do this in the responseJSON closure. The first thing to do is check if the response was successful.  if not, I print the error and call the completion handler with a false value.
```
// 10
guard response.result.isSuccess else{
  print("Error while uploading file: \(String(describing: response.result.error))")
  completion(false)
  return
}
```

Next I check each portion of the response, verifying the expected type is the actual type received. I retrieve the `firstFileID` from the response. If the `firstFileID` cannot be resolved, I print out an error message and again, call the completion handler with a false value.

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

Then I print the uploaded `fileID` and call the completion handler to update the UI.

```
// 12
print("Content uploaded with ID: \(firstFileID)")
completion(true)
```

Now, I build and run my project. I select an image and watch the progress bar change as the file uploads. When completed, I can see a note in the consol when the upload completes:

```
Content uploaded with ID: 6cda50de4521c42675cac5d269b2e87d
```

Now I'm cooking with Alamofire.

## Closing

As you can see, Alamofire provides you with an API that's relatively easy to send data over the web. We can get informed of the upload progress and read the resulting JSON. All without having dig deep into Foundation networking stack. Alamofire also gives us the ability to chain request and response methods, authentication with url credential, network reachability and a whole lot more. To learn more about Alamofire, head over to the official alamofire github page and keep coming back to raywenderlich.com for more screencasts and tutorials on iOS development. They'll get you up to speed without setting you on fire. In an alamo. But don't quote me on that. Cheers!\