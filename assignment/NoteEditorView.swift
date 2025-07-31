//
//  NoteEditorView.swift
//  assignment
//
//  Created by Jayant Dhingra on 29/07/25.
//

import Foundation
import SwiftUI

struct NoteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var note: Note?
    @State private var title: String = ""
    @State private var content: String = ""
    @FocusState private var titleFocused: Bool
    @FocusState private var contentFocused: Bool
    var onSave: (String,String) -> Void

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
                    VStack(spacing: 16) {
                        HStack {
                            Button(action: { dismiss() }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Cancel")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.4))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                            }
                            
                            Spacer()
                            
                            Text(note == nil ? "New Note" : "Edit Note")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.1))
                            
                            Spacer()
                            
                            Button(action: { 
                                onSave(title, content)
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                    Text("Save")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            title.isEmpty || content.isEmpty ? Color.gray : Color(red: 0.4, green: 0.8, blue: 0.4),
                                            title.isEmpty || content.isEmpty ? Color.gray.opacity(0.8) : Color(red: 0.3, green: 0.7, blue: 0.3)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                            }
                            .disabled(title.isEmpty || content.isEmpty)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Title")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 0.3, green: 0.5, blue: 0.3))
                                
                                TextField("Enter your note title...", text: $title)
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.9))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(titleFocused ? Color(red: 0.4, green: 0.8, blue: 0.4) : Color.clear, lineWidth: 2)
                                            )
                                    )
                                    .focused($titleFocused)
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.8))
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                            )
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Content")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 0.3, green: 0.5, blue: 0.3))
                                
                                ZStack(alignment: .topLeading) {
                                    if content.isEmpty {
                                        Text("Write your thoughts here...")
                                            .foregroundColor(Color.gray.opacity(0.6))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 16)
                                            .font(.body)
                                    }
                                    
                                    TextEditor(text: $content)
                                        .font(.body)
                                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.9))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(contentFocused ? Color(red: 0.4, green: 0.8, blue: 0.4) : Color.clear, lineWidth: 2)
                                                )
                                        )
                                        .frame(minHeight: 200)
                                        .focused($contentFocused)
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.8))
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                            )
                            
                            if title.isEmpty || content.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "lightbulb")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(Color.orange)
                                        
                                        Text("Quick Tip")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color.orange)
                                    }
                                    
                                    Text("Fill in both title and content to save your note!")
                                        .font(.subheadline)
                                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.orange.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                if let n = note { 
                    title = n.title
                    content = n.content
                } else {
                    titleFocused = true
                }
            }
        }
    }
}
