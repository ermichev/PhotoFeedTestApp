## PhotoFeedTestApp
Just a small iOS app showing photos feed from Pexels' curated photos [endpoint](https://www.pexels.com/api/documentation/#photos-curated).

### Dev notes
- Built using both UIKit (*`UICollectionView` with custom layout*) and SwiftUI.
- Uses Combine (but often in a RxSwift way, as I am more used to it).
- Has API service mock which can be used to test loading errors (can be turned on in settings).
- Can save images via `UIActivityViewController` (a little janky on iPad, but works).

### Project setup
- Pexels API key needs to be set to `API_KEY` environment variable in `PhotoFeedTestApp.xcscheme`
- Or you can just paste it in the app settings screen.

<img src="assets/light.png" width="225"/> <img src="assets/dark.png" width="225"/>
