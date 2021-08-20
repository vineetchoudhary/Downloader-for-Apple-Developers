[![Build Status](https://img.shields.io/travis/vineetchoudhary/AppBox-iOSAppsWirelessInstallation.svg?style=flat-square)](https://travis-ci.org/vineetchoudhary/Downloader-for-Apple-Developers)
[![GitHub Release](https://img.shields.io/github/release/vineetchoudhary/Downloader-for-Apple-Developers.svg?style=flat-square)](https://github.com/vineetchoudhary/Downloader-for-Apple-Developers/releases/latest)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](#license)
[![Support](https://img.shields.io/static/v1?logo=paypal&label=PayPal&message=Support&color=brightgreen&style=flat-square)](https://paypal.me/vineetchoudhary/)

## Downloader for Apple Developers
Download Xcode and other developer tools up to 16 times faster with resume capability.

## Features
- 🚀 Download Xcode and other developer tools up to 16 times faster.    
- 🎥 Download WWDC, Tech Talks and other videos up to 16 times faster.    
- ✨ Resume download automatically if the download failed due to any reason.    
- ⏬ Multiple downloads supported.

## Installation

#### Using curl
Now, you can install Downloader by running the following command in your terminal -

```bash
curl -s https://xcdownloader.com/install.sh | bash
```

#### Manual
If you face any issue using the above command then you can manually install it by downloading it from [here](https://xcdownloader.com/download). After that, unzip Downloader.app.zip and move Downloader.app into the /Applications directory.

## How to use  

#### Download Xcode and Other Developer Tools
| Step | Description |
| :--- | :--- |
| 1. | Log in with your Apple Developer Account. |
| 2. | After login, you'll see the Apple Developer Downloads page. |
| 3. | Select any file to start the download. |

#### Download WWDC, Tech Talks, and Other Videos 
| Step | Description |
| :--- | :--- |
| 1. | Select "Videos (WWDC, Tech Talks, etc.)" from the right side download source list. |
| 2. | After that, you'll see the Apple Developer Videos page. |
| 3. | Select any video which you want to download. |
| 4. | Now just select "HD Video" or "SD Video" from the Resources section to start the download. |

## Screenshots
![](/docs/CommonCover.png)
![](/docs/DownloadXcodeCover.png)

### How does it work?
Basically, this program is completely dependent on [aria2](https://aria2.github.io). `aria2` is a utility for downloading files that support segmented downloading. When we start downloading, this program takes the download auth token from cookies (as well as other required parameters), and pass them to `aria2`.

An instance of [Process](https://developer.apple.com/documentation/foundation/process) takes the output from `aria2` and shows it on UI. You can achieve the same with `aria2` without this program, but you'd have to manually take out the auth token from cookies and other parameters and feed them into `aria2`.

## Contributions
Any contribution is more than welcome! You can contribute through pull requests and [issues](https://github.com/vineetchoudhary/Downloader-for-Apple-Developers/issues) on [GitHub](https://github.com/vineetchoudhary/Downloader-for-Apple-Developers/)

## Bugs
Please post any bugs to the [issue tracker](https://github.com/vineetchoudhary/Downloader-for-Apple-Developers/issues) found on the project's GitHub page. Please include a description of what is not working right with your issue.

## Thanks
A special thanks to [Tatsuhiro Tsujikawa](https://github.com/tatsuhiro-t) and all other contributors of [aria2](https://github.com/aria2/aria2).

## License
[MIT License](/LICENSE)
