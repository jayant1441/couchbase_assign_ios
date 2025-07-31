# Notes Assignment - iOS App

iOS notes application built with SwiftUI that provides seamless note-taking with real-time cloud synchronization.

## NOTE:

For this assignment I pushed my capella credentials to Github in public repo for testing purpose (credentials should never be uploaded to github)

## Screenshots


<img width="177" height="383" alt="Simulator Screenshot - iPhone 15 Pro - 2025-07-31 at 23 57 03" src="https://github.com/user-attachments/assets/e8f83e84-3a54-48cc-beb1-3a96856ff97b" />
<img width="177" height="383" alt="Simulator Screenshot - iPhone 15 Pro - 2025-07-31 at 23 57 27" src="https://github.com/user-attachments/assets/a0b497ce-ff6a-4f2e-b62c-cae06dcce3a4" />
<img width="177" height="383" alt="Simulator Screenshot - iPhone 15 Pro - 2025-07-31 at 23 57 31" src="https://github.com/user-attachments/assets/7d7392e8-6c11-4cbf-8776-58c6523aac50" />

## YouTube Demo

[Watch here](https://youtu.be/3ycznfUqtmY)

[![Watch the video](https://img.youtube.com/vi/3ycznfUqtmY/0.jpg)](https://youtu.be/3ycznfUqtmY)

## Features

### Core Functionality

- **Create Notes**: Add new notes with title and content
- **Edit Notes**: Modify existing notes with real-time updates
- **Delete Notes**: Remove unwanted notes with confirmation
- **Offline Support**: Works seamlessly without internet connection
- **Real-time Sync**: Automatic synchronization with Couchbase Capella cloud database

## Architecture

### Design Pattern

- **MVVM (Model-View-ViewModel)**: Clean separation of concerns
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for data flow

### Key Components

#### Models

- `Note`: Core data model with id, title, content, and creation date
- `ConfigModel`: Configuration structure for database connection
- `ErrorModel`: Standardized error representation

#### Views

- `ContentView`: Main notes list interface with search and creation
- `NoteEditorView`: Full-screen note editing interface
- `NoteCard`: Individual note display component

#### Managers

- `DatabaseManager`: CouchbaseLite database operations and cloud sync
- `ErrorManager`: Centralized error handling and display
- `ConfigurationManager`: App configuration management
- `NetworkMonitor`: Network connectivity monitoring

## Technical Stack

### Frameworks & Libraries

- **SwiftUI**: UI framework
- **CouchbaseLite**: Local database
- **Combine**: Reactive programming
- **Network**: Connectivity monitoring

### Database

- **Local**: CouchbaseLite for offline storage
- **Cloud**: Couchbase Capella for real-time synchronization
- **Replication**: Bidirectional sync (push/pull)

## Getting Started

### Prerequisites

- Xcode 14.0 or later
- iOS 15.0 or later
- Active internet connection for cloud sync setup

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/jayant1441/couchbase_assign_ios
   cd assignment
   ```

2. **Open in Xcode**

   ```bash
   open assignment.xcodeproj
   ```

3. **Build and Run**
   - Select target device/simulator
   - Press `Cmd + R` to build and run

## Usage

### Creating a Note

1. Tap the "New" button in the top-right corner
2. Enter a title and content
3. Tap "Save" to create the note

### Editing a Note

1. Tap on any existing note card
2. Modify the title or content
3. Tap "Save" to update the note

### Deleting a Note

1. Tap the trash icon on any note card
2. The note will be deleted immediately

## Database Schema

### Note Document Structure

```json
{
  "type": "note",
  "id": 12345,
  "title": "Sample Note",
  "content": "This is the note content...",
  "createdAt": 1691234567.89
}
```

## Code Structure

```
assignment/
├── assignmentApp.swift          # App entry point
├── ContentView.swift            # Main interface
├── NoteEditorView.swift         # Note editing view
├── NetworkMonitor.swift         # Connectivity monitoring
├── Config/
│   ├── ConfigManager.swift      # Configuration management
│   ├── ConfigModel.swift        # Configuration data model
│   └── Config.plist            # App configuration
├── Model/
│   └── NotesModel.swift        # Note data model
├── Database/
│   └── DbManager.swift         # Database operations
└── Errors/
    ├── ErrorManager.swift       # Error handling
    └── ErrorModal.swift        # Error models
```
