/// Copyright (c) 2017 Razeware LLC
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

import UIKit
// 1
import Alamofire

class ViewController: UIViewController {

  // MARK: - IBOutlets
  @IBOutlet var takePictureButton: UIButton!
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var progressView: UIProgressView!
  @IBOutlet var activityIndicatorView: UIActivityIndicatorView!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    guard !UIImagePickerController.isSourceTypeAvailable(.camera) else { return }

    takePictureButton.setTitle("Select Photo", for: .normal)
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    imageView.image = nil
  }

  // MARK: - IBActions
  @IBAction func takePicture(_ sender: UIButton) {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.allowsEditing = false

    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      picker.sourceType = .camera
    } else {
      picker.sourceType = .photoLibrary
      picker.modalPresentationStyle = .fullScreen
    }

    present(picker, animated: true)
  }
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate {

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
    guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
      print("Info did not have the required UIImage for the Original Image")
      dismiss(animated: true)
      return
    }

    imageView.image = image
    
    takePictureButton.isHidden = true
    progressView.progress = 0.0
    progressView.isHidden = false
    activityIndicatorView.startAnimating()
    
    // 4
    //upload(image: <#T##UIImage#>, progressCompletion: <#T##(Float) -> Void#>, completion: <#T##(Bool) -> Void#>)
    
    upload(
      image: image,
      // 5
      progressCompletion: { [weak self] percent in
        guard let strongSelf = self else {
          return
        }
        
        strongSelf.progressView.setProgress(percent, animated: true)
      },
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
    })
    
    dismiss(animated: true)
  }
}

// MARK: - UINavigationControllerDelegate
extension ViewController: UINavigationControllerDelegate {
}

// MARK: - Networking calls
extension ViewController {

  // 2
  func upload(image: UIImage,
              progressCompletion: @escaping (_ percent: Float) -> Void,
              completion: @escaping (_ result: Bool) -> Void) {
    
    // 3
    guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {
      print("Could not get JPEG representation of UIImage")
      return
    }
    
    // 8
    Alamofire.upload(
      multipartFormData: { multipartFormData in
      multipartFormData.append(imageData,
                               withName: "imageFile",
                               fileName: "image.jpg",
                               mimeType: "image/jpeg")
    },
      to: "http://api.imagga.com/v1/content",
      headers: ["Authorization": "Basic YWNjX2E3MjAyMDgwODdhZTZiODphZWY5N2EyZjM3NzExYmE2ZDhhZjFmMDMzOTFkMGJmYw=="],
      encodingCompletion: { encodingResult in
        
        // 9
        switch encodingResult {
        case .success(let upload, _, _):
          upload.uploadProgress { progress in
            progressCompletion(Float(progress.fractionCompleted))
          }
          upload.validate()
          upload.responseJSON { response in
            
            // 10
            guard response.result.isSuccess else {
              print("Error while uploading file: \(String(describing: response.result.error))")
              completion(false)
              return
            }
            
            // 11
            guard let responseJSON = response.result.value as? [String: Any],
              let uploadedFiles = responseJSON["uploaded"] as? [Any],
              let firstFile = uploadedFiles.first as? [String: Any],
              let firstFileID = firstFile["id"] as? String else {
                print("Invalid information received from service")
                completion(false)
                return
            }
            
            // 12
            print("Content uploaded with ID: \(firstFileID)")
            completion(true)
          }
        case .failure(let encodingError):
          print(encodingError)
        }
    })
  }
}
