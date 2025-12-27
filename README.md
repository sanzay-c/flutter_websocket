# Flutter WebSocket with BLoC and Clean Architecture

This Flutter project demonstrates how to implement WebSockets using the free WebSocket API `wss://echo.websocket.org`, with state management handled by the BLoC (Business Logic Component) pattern and following Clean Architecture principles. Additionally, this project includes a CI/CD workflow setup for continuous integration and deployment.

## Introduction

In this project, we explore how to integrate WebSocket functionality into a Flutter application using the free WebSocket API `wss://echo.websocket.org`. This service simply echoes back any message sent to it, making it a great tool for testing WebSocket functionality.

We follow the **Clean Architecture** pattern to ensure a maintainable and modular codebase, with **BLoC** for state management, which separates the business logic from the UI. Additionally, the project includes a CI/CD pipeline setup using GitHub Actions for automated testing, building, and deployment.

---

## Technologies Used

- **Flutter**: UI framework for building natively compiled applications for mobile, web, and desktop from a single codebase.
- **Dart**: Programming language used for Flutter development.
- **WebSocket**: Protocol for full-duplex communication channels over a single TCP connection.
- **BLoC**: A state management pattern in Flutter that separates business logic from the UI.
- **Clean Architecture**: A design pattern that promotes separation of concerns and makes the code more modular, testable, and maintainable.
- **CI/CD**: Continuous Integration/Continuous Deployment for automating the build, test, and deployment processes.

---

## Packages Used

- [`flutter_websocket`](https://pub.dev/packages/flutter_websocket): A package for using WebSockets in Flutter.
- [`flutter_bloc`](https://pub.dev/packages/flutter_bloc): A Flutter package that implements the BLoC pattern.
- [`equatable`](https://pub.dev/packages/equatable): A package that makes value comparison easy and works well with BLoC.
- [`get_it`](https://pub.dev/packages/get_it): A service locator for dependency injection. 

## Project Structure

The project follows the **Clean Architecture** pattern. Below is the folder structure:

