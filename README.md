# MMSCropView

[![CI Status](http://img.shields.io/travis/miller-ms/MMSCropView.svg?style=flat)](https://travis-ci.org/miller-ms/MMSCropView)
[![Version](https://img.shields.io/cocoapods/v/MMSCropView.svg?style=flat)](http://cocoapods.org/pods/MMSCropView)
[![License](https://img.shields.io/cocoapods/l/MMSCropView.svg?style=flat)](http://cocoapods.org/pods/MMSCropView)
[![Platform](https://img.shields.io/cocoapods/p/MMSCropView.svg?style=flat)](http://cocoapods.org/pods/MMSCropView)
[![Readme Score](http://readme-score-api.herokuapp.com/score.svg?url=miller-ms/MMSCropView)](http://clayallsopp.github.io/readme-score?url=miller-ms/MMSCropView)

This class provides the feature to draw a rectangle over an image by dragging a finger over it, move it, and extract the covered region into a UIImage.
<p align="center">
<img src="screenshot.png” alt="Sample">
</p>
## Usage
To run the example project, clone the repo, and run `pod install` from the Example directory first.

In your storyboard select the custom class MMSCropImageView for the Image View widget.

Import the class header.
``` swift
import MMSCropView
```

Add an event handler to initiate the crop action and call the crop method on the image view.

``` swift
@IBAction func crop(sender: UIButton) {

    let croppedImage = originalImageView.crop()

    croppedImageView.image = croppedImage

}
```

## Requirements

*MMSCropView requires iOS 8.3 or later.*

## Installation

MMSCropView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MMSCropView"
```

## Author

William Miller, support@millermobilesoft.com

## Article

An article describing the implementation of the class:  [A View Class for Cropping Images](http://www.codeproject.com/Articles/1066191/A-View-Class-for-Cropping-Images).

## Contact

William Miller

- http://github.com/miller-ms
- support@millermobilesoft.com

## License

This project is is available under the MIT license. See the LICENSE file for more info. Attribution by linking to the [project page](https://github.com/miller-ms/MMSCropView) is appreciated.