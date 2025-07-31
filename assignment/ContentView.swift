//
//  ContentView.swift
//  assignment
//
//  Created by Jayant Dhingra on 29/07/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var errorManager = ErrorManager.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @State private var notes: [Note] = []
    @State private var showingEditor = false
    @State private var editNote: Note? = nil
    @State private var showingError = false
    @State private var currentError: ErrorModel?
    private let db = DatabaseManager.shared

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.98, green: 0.87, blue: 0.79),
                        Color(red: 0.95, green: 0.82, blue: 0.73),
                        Color(red: 0.92, green: 0.77, blue: 0.67)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("My Notes")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                
                                Text("\(notes.count) \(notes.count == 1 ? "note" : "notes")")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                            }
                            
                            Spacer()
                            
                            Button(action: { 
                                editNote = nil
                                showingEditor = true 
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .bold))
                                    Text("New")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.4, green: 0.8, blue: 0.4),
                                            Color(red: 0.3, green: 0.7, blue: 0.3)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(25)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                            }
                            .scaleEffect(1.0)
                            .animation(.easeInOut(duration: 0.1), value: showingEditor)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        if !networkMonitor.isConnected {
                            HStack(spacing: 8) {
                                Image(systemName: "wifi.slash")
                                    .font(.system(size: 14, weight: .medium))
                                Text("Offline Mode")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    if notes.isEmpty {
                        VStack(spacing: 24) {
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "note.text")
                                    .font(.system(size: 50, weight: .light))
                                    .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.2))
                            }
                            
                            VStack(spacing: 12) {
                                Text("No notes yet")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                                
                                Text("Tap the 'New' button to create\nyour first amazing note")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 40)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(notes) { note in
                                    NoteCard(note: note) {
                                        editNote = note
                                        showingEditor = true
                                    } onDelete: {
                                        withAnimation(.spring()) {
                                            db.deleteElement(note)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingEditor) {
            NoteEditorView(note: $editNote) { title, content in
                let noteId = editNote?.id ?? Int.random(in: 1...Int.max)
                let n = Note(id: noteId, title: title, content: content, createdAt: Date())
                withAnimation(.spring()) {
                    if editNote != nil {
                        db.updateExistingElement(n)
                    } else {
                        db.addNewElement(n)
                    }
                }
                showingEditor = false
            }
        }
        .alert("Error", isPresented: $showingError, presenting: currentError) { error in
            Button("OK") {
                errorManager.dismissNext()
            }
        } message: { error in
            Text(error.message)
        }
        .onAppear { 
            db.queryElements() 
        }
        .onReceive(db.notesPublisher) { newNotes in
            withAnimation(.spring()) {
                notes = newNotes 
            }
        }
        .onReceive(errorManager.$errors) { errs in
            if let e = errs.first {
                currentError = e
                showingError = true
            }
        }
    }
}

struct NoteCard: View {
    let note: Note
    let onTap: () -> Void
    let onDelete: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(note.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.2))
                        .lineLimit(2)
                    
                    Text(note.content)
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(note.createdAt, style: .date)
                            .font(.caption)
                    }
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.red.opacity(0.7))
                        .padding(8)
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.8))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) { isPressing in
            isPressed = isPressing
        } perform: {}
    }
}
