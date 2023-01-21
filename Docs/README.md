<div align="center">
 
# Sauron-iOS
### Keep your eye in the sky with this modern, robust, and responsive crypto tracker 
 🔥👁🔥
 
[![Swift Version badge](https://img.shields.io/badge/Swift-5.7.1-orange.svg)](https://shields.io/)
[![Platforms description badge](https://img.shields.io/badge/Platform-iOS-blue.svg)](https://shields.io/)
[![GitHub version](https://badge.fury.io/gh/jcook03266%2FSauron-iOS.svg)](https://badge.fury.io/gh/jcook03266%2FSauron-iOS)
 
</div>

<div align="center">
 
<img src="https://github.com/jcook03266/Sauron-iOS/blob/dev/Resources/Sauron-iOS-MVP-Collage.png" width = "800">
 
</div>

<div align="center">

<details>
<summary> Quick Navigation </summary> 

* [Project Summary ⇲](#Project-Summary)
* [Design Patterns ⇲](#Design-Patterns-Used)
* [Frameworks ⇲](#Frameworks-Used)
* [Libraries ⇲](#Libraries-Used)
* [Internal iOS APIs ⇲](#Internal-iOS-APIs-In-Use)
* [External APIs ⇲](#External-APIs-In-Use)
* [Handling Sensitive User Data ⇲](#Handling-Sensitive-User-Data)
* [FTUE Onboarding Demo ⇲](#FTUE-Onboarding-Demo)
* [Optional Authentication Gateway Demo ⇲](#Optional-Authentication-Gateway-Demo)
* [Thirdparty Services Used for Development ⇲](#Thirdparty-Services-Used-for-Development)
* [Important Advisory ⇲](#Important-Advisory)
</details>
</div>

<div align="left">
 
## Project Summary:
Sauron is a project I set out to create in order to showcase my iOS development skillset and growth potential. This application was designed by me in the span of 2 days using Figma to create design resource templates, mockup screens, and placeholder assets. Built completely in SwiftUI, from the application delegate, to the view navigation logic, this app uses the latest technologies enabled by the powerful declarative programming SwiftUI framework to bring to life a truly responsive experience. Sauron spans many different scenes that are uniquely displayed in their own way, and to satisfy this dynamic and ready-when-needed view hierarchy I relied on the coordinator pattern mixed with the router pattern to abstract control away from the view logic. I'm a firm believer of simplifying applications through separation of powers, your views are not supposed to present themselves, and your view models should not be responsible for creating views either. By dividing up all of these responsibilities through the MVVM pattern I'm able to make the app both maintainable and testable due to each screen having zero dependencies on one another.
 
This is a common pattern I set out to apply to the overall design of this app, a service-oriented, managed hierarchy of data and views where each component can function on its own and doesn't have to know what the other component is doing in order to function. Modularity and availability is what you should take away from this project if you're using it as a learning guide; those two design criteria make both development and debugging easier to do in the short and long term. Dependency injection, subscriptions, protocols, services, and concurrency are the most useful techniques I've used to make this project a reality as they've greatly cut down my development time by removing the need for repetitive code. Speaking of repetitive code, coordinators and routers created a lot of overhead that needed to be dealt with whenever I had to layout a coordinated scene that transitions to another on the fly, but this overhead was necessary in order to delegate navigation control to the coordinators, and view instantiation to the routers.
 
All in all I highly recommend using SwiftUI for your next personal project or commercial application. The framework is maturing faster and faster and offers the same capabilities as UIKit when you wrap a UIView in a SwiftUI View. The sky is the limit and I hope this cryptocurrency tracker can serve as a cool intermediate learning resource for those wanting to expand their understanding of SwiftUI to a professional level.

## Design Patterns Used:
* Coordinator
* Router
* MVVM
* Dependency Injection
* Factory
* Services
* Data Provider
* Data Store
* Manager
* Singleton
* Protocol

## Frameworks Used:
* SwiftUI / UI and screen navigational logic
* UIKit / SwiftUI View wrapping and design resources
* Combine / publishers/subscribers/cancellables/maps
* Concurrency / async/await/futures 
* CoreData / Data Persistence
* Network / Internet Connection Monitoring
* Darwin / Generating randomized salt
* LocalAuthentication / FaceID

## Libraries Used:
* Lottie-iOS
* swift-collections
* SwiftUI-Shimmer
* CryptoSwift

## Internal iOS APIs In Use:
* UserDefaults
* Localization

## External APIs In Use:
* CoinGecko's Cryptocurrency Coin API
* Exchangerate.host Global Exchange Rate API

</div>

<div align="left">

## Handling Sensitive User Data
When it comes to end-user information, Sauron doesn't store user data remotely; all relevant information is localized on the user's device in secure stores and local databases, but this offline persistence layer doesn't mean security shouldn't be taken into consideration. The app's main content is open to access via the user with full clearance, however, if the user chooses to do so they can specify an authentication method to use in order to grant them access to their personalized app data. These authentication methods are your usual faceID biometrics, and a custom passcode. The proprietary passcode security layer Sauron uses is very robust as it uses the Scrypt hashing algorithm combined with a randomized salt to encrypt the user's passcode, which therefore increases the difficulty of cracking the passcode without brute forcing it first. 

And speaking of brute force, since the passcode is only 4 digits, which is relatively easy to crack since there's only 10^4 (10,000) possible combinations to try before getting access, another added layer of security is the persistent cool down Sauron makes use of that keeps bad actors at bay. The persistent cool down keeps track of a static date at which it will expire and allow the user to retry their passcode again, following their first 5 unsuccessful attempts. The cool down also lasts for 5 minutes, which will slow down any potential attackers by an order of 10,000/5 * 5 = 10,000 minutes aka 166.67 hours; wasting all system resources on single instance brute force machines, as the machine will idle in the cool down period in 5 minute intervals. 

Going further, please keep in mind that this solution isn't a magic bullet, it won't solve any and all problems, nor will it guarantee 100% safety of a user's sensitive data, it's more like a firewall to keep intruders out at the request of the user. Another note would be that cryptographic security measures are incredibly hardware intensive so fine-tuning the parameters for the Scrypt algorithm was a bit of trial and error when it came to ensuring performance ~ 1 second results, and added security from iterative hashing. Only perform this hashing on a separate thread, if you do it on the main thread with the rest of the UI the user interface WILL seize up and potentially crash, so try to perform it on a background thread if your UI is currently active while the algorithm is functioning. I also highly recommend using this best practice for passwords that include characters beyond numerical digits, as the more personalized and variable the password, the better the odds of the password remaining secure, even in the event of a data leak. 

</div>

<div align="center">

## FTUE Onboarding Demo:

https://user-images.githubusercontent.com/63657230/212473279-acb62b56-8b78-457f-8593-99eb56780c4a.mp4

</div>

<div align="center">

## Optional Authentication Gateway Demo:

https://user-images.githubusercontent.com/63657230/213864245-1df46285-1e69-43c7-8db2-b055afafaa98.MP4

</div>

## Thirdparty Services Used for Development:
- <a href="https://app.quicktype.io/"> Quicktype.io </a> | JSON Swift Data Model Parsing
- <a href="https://www.figma.com/"> Figma.com </a> | Design / Wireframing

### Important Advisory: 
*This repository is not licensed, and is not available for commercial use.*
