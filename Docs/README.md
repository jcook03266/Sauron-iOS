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

* [Project Summary ⇲ ](#Project-Summary)
* [Design Patterns ⇲ ](#Design-Patterns-Used)
* [Frameworks ⇲ ](#Frameworks-Used)
* [Libraries ⇲ ](#Libraries-Used)
* [Internal iOS APIs ⇲ ](#Internal-iOS-APIs-In-Use)
* [External APIs ⇲ ](#External-APIs-In-Use)
* [FTUE Onboarding Demo ⇲](#FTUE-Onboarding-Demo)
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

## Libraries Used:
* Lottie-iOS
* swift-collections
* SwiftUI-Shimmer

## Internal iOS APIs In Use:
* UserDefaults
* Localization

## External APIs In Use:
* CoinGecko's Cryptocurrency Coin API
* Exchangerate.host Global Exchange Rate API

</div>

<div align="center">

## FTUE Onboarding Demo:

https://user-images.githubusercontent.com/63657230/211432621-c670414b-313d-4a10-a6fd-9f56ccb3a570.mp4

</div>

## Thirdparty Services Used for Development:
- <a href="https://app.quicktype.io/"> Quicktype.io </a> | JSON Swift Data Model Parsing
- <a href="https://www.figma.com/"> Figma.com </a> | Design / Wireframing

### Important Advisory: 
*This repository is not licensed, and is not available for commercial use.*
