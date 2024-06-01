//
//  Notebook2Screen.swift
//  Notebook2
//
//  Created by Андрей Завадский on 17.05.2024.
//

import SwiftUI

// А чего не просто Note?// поправил, когда делал в соседнем окне был Note, чтобы не было ошибки тут сделал Note2.
struct Note: Identifiable, Codable {
    var id = UUID()
    var text: String
}
class NotesManager: ObservableObject {
    @Published var notes: [Note] = []
    init() {
        loadNotes()
    }
    func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            UserDefaults.standard.set(data, forKey: "notes")
        } catch {
            print("Error encoding notes: \(error.localizedDescription)")
        }
    }
    func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: "notes") {
            do {
                notes = try JSONDecoder().decode([Note].self, from: data)
            } catch {
                print("Error decoding notes: \(error.localizedDescription)")
            }
        }
    }
    
    
}

struct NotebookScreen: View {
    @StateObject private var notesManager = NotesManager()
    @State private var editingText: String = "" // тут бы более понятный нейминг, типа currentText или editingText // исправил
    @State private var isEditing = false // для чего это поле?// нужно для отслеживания нажатия на заметку для редактирования/удаления
    @State private var selectedNoteID: UUID?
    
    var body: some View {
   //     NavigationView {
            
            
            VStack {
                ScrollView {
                    // Note2 - это Identifiable, на это никак не используется. Либо Identifiable, либо, что мне больше нравится использовать ForEach(notes2) {...} и в остальных местах вместо selectedNoteIndex использовать selectedNoteID// поправил
                    ForEach(notesManager.notes) { note in
                        Text(note.text).padding(.trailing, 200)
                            .onTapGesture {
                                isEditing = true
                                editingText = note.text
                                selectedNoteID = note.id
                            }
                    }
                    
                        
                    
                    TextField("Введите заметку", text: $editingText)
                        .padding()
                        .textInputAutocapitalization(.words)
                        .onSubmit {
                            saveNote()
                        }
                   
                }
                .navigationTitle("Список")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        // Внутри Button много кода на мой взгляд, я бы это уже выносил в отдельный метод
                        Button {
                            saveNote()
                        } label: {
                            Text("Сохранить")
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        // Внутри Button много кода на мой взгляд, я бы это уже выносил в отдельный метод
                        Button {
                            deleteNote()
                        } label: {
                            Image(.trash)
                        }
                    }
                    
                    
                }.navigationBarTitleDisplayMode(.inline)
                
                
            }
            
            
  //      }
        
    }
    
    
    func deleteNote() {
        if let id = selectedNoteID {
            if let index = notesManager.notes.firstIndex(where: { $0.id == id }) {
                notesManager.notes.remove(at: index)
                notesManager.saveNotes()
                resetEditingState() // Reset the editing state
                
            }
        }
    }
    
    // Функция для сохранения заметки
    func saveNote() {
        if let id = selectedNoteID {
            if let index = notesManager.notes.firstIndex(where: { $0.id == id }) {
                notesManager.notes[index].text = editingText
            }
        } else {
            notesManager.notes.append(Note(text: editingText))
        }
        notesManager.saveNotes()
        resetEditingState() // Call a function to reset state
    }
    // Функция сброса состояния редактирования
    func resetEditingState() {
        editingText = ""
        selectedNoteID = nil
        isEditing = false
    }
}

#Preview {
    NavigationStack {
        NotebookScreen()
    }
}



//struct AddNote: View {
//    var body: some View {
//        Button {
//            if let index = selectedNoteID {
//                notesManager.notes[index].text = editingText
//            } else {
//                notesManager.notes.append(Note(text: editingText))
//            }
//            notesManager.saveNotes()
//            editingText = ""
//            selectedNoteID = nil
//
//        } label: {
//
//            Image(.plus)
//                .padding()
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(8)
//
//        }.background(Color(.white))
//    }
//}

