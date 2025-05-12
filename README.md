# learnIt: Personal AI Learning Companion (SwiftUI)

![Projects (1)](https://github.com/user-attachments/assets/bc3a1530-1aed-4458-9e15-0f2bfe00c20d)

A iOS application built with SwiftUI that uses the OpenAI API to instantly generate summaries, interactive quizzes, and predicted questions for any topic. Developed as a personal tool for efficient learning and a hands-on project to master API integration and complex SwiftUI architecture.

## Purpose

This project was created for my personal use and learning, specifically to:

* Learn how to integrate with external APIs (OpenAI) in a SwiftUI application.
* Practice parsing complex JSON responses from an API.
* Implement a multi-screen SwiftUI application using `TabView` and `NavigationView`.
* Explore state management (`@State`, `@ObservedObject`, `@StateObject`) in complex views.
* Implement local data persistence using `UserDefaults` for bookmarks.
* Develop custom UI components (like the quiz card stack if that's custom).
* Create a personal utility to aid my own learning process.

## Status

*(Note the current status for yourself - e.g., In Development, Functional, Complete)*

## Features

* **Generate Content:** Input any topic to receive a generated summary, quiz, and predicted questions using the OpenAI API.
* **Interactive Quiz:** Take a short multiple-choice quiz generated from the topic summary.
* **Predicted Questions:** See related questions the AI thinks you might have.
* **Bookmarks:** Save generated content (summary, quiz, predicted questions) for later review.
* **Bookmark Details:** View saved content in a dedicated detail screen.
* **Settings:** (Based on files) Includes options like clearing cached bookmarks ("Clear Cache").
* **Tabbed Navigation:** Easy navigation between Home, Bookmarks, and Settings screens.

## Technical Architecture & Implementation Details

* **UI:** Built entirely with **SwiftUI**.
* **Networking:** `NetworkController.swift` handles communication with the OpenAI API.
* **API Interaction:** Sends a formatted prompt to the `gpt-3.5-turbo` model (based on `NetworkController.swift`).
* **Data Parsing:** `OpenAIChatResponse.swift` and static methods in `OpenAIResponse.swift` are responsible for parsing the specific format of the AI response into usable Swift data structures (`OpenAIResponse` struct).
* **State Management:** Uses `@State`, `@ObservedObject`, and `@StateObject` to manage UI state and data flow, particularly in `HomeView` and `TimerViewModel` (if TimerViewModel is still part of this project - *Note: Timer files seemed to be from PanDrop, double-check if they are linked here*).
* **Local Persistence:** `UserDefaults` is used to save and load bookmarks (`UserDefaults` extension).
* **Navigation:** `MainTabView.swift` sets up the primary `TabView`, and `NavigationLink` is used within views for screen transitions.

### Key Files:

* `learnItApp.swift`: App entry point.
* `MainTabView.swift`: Sets up the main tab bar navigation.
* `HomeView.swift`: Handles topic input, calling the API, displaying results, and the interactive quiz.
* `BookmarksView.swift`: Displays saved learning content. `BookmarkDetailView` shows full saved content.
* `SettingsView.swift`: Provides app settings (like clearing bookmarks).
* `NetworkController.swift`: Contains the logic for making API calls to OpenAI.
* `OpenAIChatResponse.swift`: Structs for decoding the raw JSON response from OpenAI.
* `OpenAIResponse.swift`: Struct for the parsed, application-specific data (`summary`, `quizQuestions`, `predictedQuestions`). Includes parsing logic.

## To-Do / Challenges
* **API Key:** Remember the OpenAI API key is stored in `NetworkController.swift`. (Keep this file secure and *never* commit it to a public repository with the key).
* **Parsing Logic:** The parsing in `OpenAIResponse.swift` relies heavily on the specific format requested in the `systemPrompt`. Any changes to the prompt format would require updating the parsing logic.
* **Error Handling:** (Note any specific error handling logic or areas for improvement).
* **UI Improvements:** (List any UI enhancements you might want to make later).
* **Future Ideas:** (e.g., adding more quiz types, different AI models, user accounts, syncing bookmarks).
* **Challenges:** (Briefly describe any tricky parts you overcame, like parsing the quiz format or managing state across tabs).

## Privacy Note

This is a private repository containing a personal project for my own use. It is not intended for public installation, use, or contribution.

This README provides a detailed overview for your own reference. Remember to replace the placeholder screenshot links with actual images and adjust any sections based on the exact state and components of your project. This will be a valuable document for you as you revisit or continue working on `learnIt`.
