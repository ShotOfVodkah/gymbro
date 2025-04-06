//
//  EditProfile.swift
//  GymBro
//
//  Created by Александра Грицаенко on 05/04/2025.
//

import SwiftUI
import FirebaseAuth

struct EditProfile: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var vm = FeedListModel()
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

#Preview {
    EditProfile()
}
