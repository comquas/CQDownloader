# CQDownloader

![](https://cldup.com/8SeLTKh3Jj.png)

Base on the [https://github.com/wibosco/BackgroundTransfer-Example](https://github.com/wibosco/BackgroundTransfer-Example)

- [x] Downloading
- [x] Download with progress callback
- [x] Download finish callback
- [x] Pause/Resume (90% done)
- [x] With TableView Design
- [ ] More Error Checking
- [ ] Fixed for background update disable and went to the background, need to pause and allow to resume

## Usages

Nee to add following code in `AppDelegate.swift`

```
func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
    CQDownloader.shared.backgroundCompletionHandler = completionHandler
}
```

```
let downloader = CQDownloader.shared
```

You can pass any string data to data model. Passing `Title` in the following example. 

```
self.downloader.download(remoteURL: remoteURL, filePathURL: filepath, data: ["Title": number], onProgressHandler: { (downloadItem:CQDownloadItem) in

}) { (result:DataRequestResult<URL>) in

}
```
Can check the example at `TableViewController.swift`

## Known Issues

### Not working for redirect download

Currently key is using download URL. When resume, we cannot get back the `originalRequest`. So, I use the `currentRequest`. If URL is redirecting, current `originalRequest` and `currentRequest` may different. 

Here is how I get the requesturl from download task.
```
var requestURL = downloadTask.originalRequest?.url
if requestURL == nil {
    requestURL = downloadTask.currentRequest?.url
}
```

# Logs

## 30 Jul 2019

- Fixed for Xcode 10.3
