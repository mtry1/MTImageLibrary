# Usage

picker

```
MTImageLibrary.sharedInstance.show(inController: self).error { (message) in
    print(message)
}.picker(maxNumber: 3) { (images) in
    print(images)
}

```

croper

```
MTImageLibrary.sharedInstance.show(inController: self).error { (message) in
    print(message)
}.croper { (image) in
    self.imageView.image = image
}
```

# Requirements

- Swift 3.0
- iOS 8.0 or later
