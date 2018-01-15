# SSImagePickerController
a simple image picker controller

## Usage
```
SSImagePickerController *imagePickerViewCtrl = [[SSImagePickerController alloc] init];
imagePickerViewCtrl.delegate = self;
imagePickerViewCtrl.maxCount = 6; // Set Max Images count
[self presentViewController:imagePickerViewCtrl animated:YES completion:nil];
```
## Requirements

* Xcode 9.0
* Objective-c 6.0 or later
* Masonry 

## Installation

These are currently the supported options:

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

```ruby
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'SSImagePickerController', '~> 0.1.4'
end
```

### Manual

Drag the SSImagePickerController folder in your project, import the header file: # import "SSImagePickerController.h"
