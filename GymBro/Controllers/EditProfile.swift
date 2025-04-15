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
    @State var email = ""
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
                        HStack {
                            InfoField(title: Text("Email"), isNumber: false, text: .constant(email))
                                .disabled(true)
                            Spacer()
                            Image(systemName: "lock.fill")
                                .foregroundColor(Color("PurpleColor"))
                        }
                        InfoField(title: Text("Bio"), isNumber: false, text: $bio)
                        InfoField(title: Text("Age"), isNumber: true, text: $age)
                        GenderPickerField(title: Text("Gender"), selectedGender: $gender, shouldShowArrow: true)
                        HStack {
                            InfoField(title: Text("Weight (kg)"), isNumber: true, text: $weight)
                            InfoField(title: Text("Height (cm)"), isNumber: true, text: $height)
                        }
                    }
                    .padding()
                    Spacer()
                }
            }
            .onChange(of: vm.chatUser) { _ in
                guard let user = vm.chatUser else { return }
                email = user.email
                username = user.username
                bio = user.bio
                gender = user.gender
                age = user.age
                weight = user.weight
                height = user.height
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
                    .frame(width: 100, alignment: .leading)
            }
            Spacer()
            Text("Edit Profile")
                .font(.system(size: 28))
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TitleColor"))
                .padding(.horizontal, 5)
            Spacer()
            Button {
                vm.updateUserData(username: username, bio: bio, gender: gender, age: age, weight: weight, height: height)
                dismiss()
            } label: {
                Text("Save")
                    .font(.system(size: 20))
                    .foregroundColor(Color("TitleColor"))
                    .frame(width: 100, alignment: .trailing)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }
}

#Preview {
    EditProfile()
}
