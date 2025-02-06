//
//  ContentView.swift
//  GymBro
//
//  Created by Stepan Polyakov on 18.11.2024.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct LoginView: View {
    
    @State var isLoginMode: Bool = false
    @State var email: String = ""
    @State var password: String = ""
    
    @State var shouldShowImagePicker: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                VStack(spacing: 20) {
                    Picker(selection: $isLoginMode, label: Text("picker here")) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    if !isLoginMode {
                        Button {
                            shouldShowImagePicker.toggle()
                        } label: {
                            VStack {
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 130, height: 130)
                                        .cornerRadius(130 / 2)
                                        .overlay(RoundedRectangle(cornerRadius: 130 / 2)
                                            .stroke(Color("PurpleColor"), lineWidth: 3))
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 130))
                                        .foregroundColor(Color("PurpleColor"))
                                        .padding()
                                }
                            }
                        }
                    }
                    
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                    }   .padding(12)
                        .background(.white)
                    
                    Button {
                        handleAction()
                    } label: {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 15)
                            Spacer()
                        }.background(Color("PurpleColor"))
                    }
                    
                    Text(self.loginStatusMessage)
                        .foregroundColor(.red)
                }
                .padding()
            }
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.1)))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
        }
    }
    
    private func handleAction() {
        if isLoginMode {
            loginUser()
        } else {
            createNewAccount()
        }
    }
    
    @State var loginStatusMessage = "";
    
    private func createNewAccount() {
        Auth.auth().createUser(withEmail: email, password: password) {
            result, error in
            if let error = error {
                print("Failed to create user:", error.localizedDescription)
                self.loginStatusMessage = "Failed to create user: \(error.localizedDescription)"
                return
            }
            print("Succeeded to create user: \(result?.user.uid ?? "")")
            loginStatusMessage = "Succeeded to create user: \(result?.user.uid ?? "")"
            
//            self.persistImageToStorage() надо будет оплатить подписку и подключить Storage
            self.storeUserInformation()
        }
    }
    
    private func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) {
            result, error in
            if let error = error {
                print("Failed to login user:", error.localizedDescription)
                self.loginStatusMessage = "Failed to login user: \(error.localizedDescription)"
                return
            }
            print("Succeeded to login user: \(result?.user.uid ?? "")")
            loginStatusMessage = "Succeeded to login user: \(result?.user.uid ?? "")"
        }
    }
    
    @State var image: UIImage?
    
    private func persistImageToStorage() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Storage.storage().reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) {
            metadata, error in
            if let error = error {
                self.loginStatusMessage = "Failed to upload image: \(error.localizedDescription)"
                return
            }
            
            ref.downloadURL {
                url, error in
                if let error = error {
                    self.loginStatusMessage = "Failed to download URL: \(error.localizedDescription)"
                    return
                }
                self.loginStatusMessage = "Image uploaded successfully with URL: \(url?.absoluteString ?? "")"
                print("Download URL: \(url?.absoluteString ?? "")")
                guard let url = url else { return }
//                self.storeUserInformation(imageProfileURL: url)
            }
        }
    }
    
    private func storeUserInformation() {
//    private func storeUserInformation(imageProfileURL: URL?) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = ["uid": uid, "email": self.email]
//        "profileImageURL": imageProfileURL.absoluteString
        Firestore.firestore().collection("usersusers")
            .document(uid).setData(userData) {
                error in
                if let error = error {
                    print(error.localizedDescription)
                    self.loginStatusMessage = "Error storing user data: \(error.localizedDescription)"
                    return
                }
                print("User data stored successfully")
            }
    }
}


#Preview {
    LoginView()
}

