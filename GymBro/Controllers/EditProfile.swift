//
//  EditProfile.swift
//  GymBro
//
//  Created by Александра Грицаенко on 05/04/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EditProfile: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var vm = AccountModel()
    @State var email = Auth.auth().currentUser?.email ?? ""
    @State var username = ""
    @State var bio = ""
    @State var gender = ""
    @State var age = ""
    @State var weight = ""
    @State var height = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Background").ignoresSafeArea()
                VStack {
                    customTitleBar
                        .padding(.bottom, 5)
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(Color("PurpleColor"))
                    
                    VStack {
                        InfoField(title: Text("Username"), isNumber: false, text: $username)
                        InfoField(title: Text("Email"), isNumber: false, text: $email)
                        InfoField(title: Text("Bio"), isNumber: false, text: $bio)
                        InfoField(title: Text("Age"), isNumber: true, text: $age)
                        GenderPickerField(title: Text("Gender"), selectedGender: $gender)
                        HStack {
                            InfoField(title: Text("Weight (kg)"), isNumber: true, text: $weight)
                            InfoField(title: Text("Height (cm)"), isNumber: true, text: $height)
                        }
                    }
                    .padding()
                    Spacer()
                }
            }
        }
    }
    
    private var customTitleBar: some View {
        HStack () {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .font(.system(size: 20))
                    .foregroundColor(Color("TitleColor"))
                    .padding(.trailing, 20)
            }
            Text("Edit Profile")
                .font(.system(size: 30))
                .fontWeight(.semibold)
                .foregroundColor(Color("TitleColor"))
                .padding(.horizontal, 20)
            Button {
                // save changes
            } label: {
                Text("Save")
                    .font(.system(size: 20))
                    .foregroundColor(Color("TitleColor"))
                    .padding(.leading, 30)
            }
        }
    }
}

class AccountModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isUserCurrentlyLoggedOut: Bool = false
    
    init() {
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = Auth.auth().currentUser?.uid == nil
        }
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
        Firestore.firestore().collection("usersusers").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Error fetching user: \(error.localizedDescription)"
                print("Faild to fetch user: \(error.localizedDescription)")
                return
            }
            guard let data = snapshot?.data() else {
                self.errorMessage = "No user data"
                return
            }
            
            self.chatUser = .init(data: data)
        }
    }
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? Auth.auth().signOut()
    }
}

#Preview {
    EditProfile()
}
