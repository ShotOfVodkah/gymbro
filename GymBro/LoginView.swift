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
    
    let didCompleteLogin: () -> ()
    
    @State var isLoginMode: Bool = false
    @State var email: String = ""
    @State var password: String = ""
    @State var bio = ""
    @State var gender = ""
    @State var age = ""
    @State var weight = ""
    @State var height = ""
    
    @State var shouldShowImagePicker: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .foregroundStyle(.linearGradient(colors: [Color("PurpleColor"), .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 1000, height: 400)
                    .rotationEffect(.degrees(135))
                    .offset(x: -30, y: -370)
                    .opacity(1.0)
                
                VStack(spacing: 10) {
                    
                    Text("GymBro")
                        .font(.system(size: 40, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .offset(x: -75, y: -210)
                    Text("Welcome to GymBro")
                        .font(.system(size: 20, weight: .light, design: .default))
                        .foregroundColor(.white)
                        .offset(x: -75, y: -210)
                    
                    TextField("", text: $email)
                        .foregroundColor(.white)
                        .textFieldStyle(.plain)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .placeholder(when: email.isEmpty) {
                            Text("Email")
                                .foregroundColor(.white)
                                .bold()
                        }
                        .offset(y: -40)
                    Rectangle()
                        .frame(width: 350, height: 1)
                        .foregroundColor(.white)
                        .offset(y: -40)
                    
                    SecureField("", text: $password)
                        .foregroundColor(.white)
                        .textFieldStyle(.plain)
                        .placeholder(when: password.isEmpty) {
                            Text("Password")
                                .foregroundColor(.white)
                                .bold()
                        }
                        .offset(y: -30)
                    Rectangle()
                        .frame(width: 350, height: 1)
                        .foregroundColor(.white)
                        .offset(y: -30)
                    
                    Button {
                        if isLoginMode {
                            loginUser()
                        } else {
                            createNewAccount()
                        }
                    } label: {
                        Text(isLoginMode ? "Log in" : "Create Account")
                            .bold()
                            .frame(width: 200, height: 40)
                            .background(RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.linearGradient(colors: [Color("PurpleColor"), .purple], startPoint: .top, endPoint: .bottomTrailing)))
                            .foregroundColor(.white)
                    }
                    .padding(.top)
                    .offset(y: 120)
                    
                    Button {
                        isLoginMode.toggle()
                    } label: {
                        Text(isLoginMode ? "Don't have an Account? Create a new one!" : "Already have an account? Login")
                            .bold()
                            .foregroundColor(.white)
                    }
                    .padding(.top)
                    .offset(y: 120)
                }
                .frame(width: 350)
            }
        }
    }
    
    @State var loginStatusMessage = "";
    
    private func createNewAccount() {
//        if self.image == nil {
//            self.loginStatusMessage = "Please select a profile picture."
//            return
//        }
        
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
            self.loginStatusMessage = "Succeeded to login user: \(result?.user.uid ?? "")"
            self.didCompleteLogin()
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
//                guard let url = url else { return }
//                self.storeUserInformation(imageProfileURL: url)
            }
        }
    }
    
    private func storeUserInformation() {
//    private func storeUserInformation(imageProfileURL: URL?) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = ["uid": uid, "email": self.email, "username": self.email.replacingOccurrences(of: "@gmail.com", with: ""), "bio": self.bio, "gender": self.gender, "age": self.age, "weight": self.weight, "height": self.height]
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
                self.didCompleteLogin()
            }
    }
}


#Preview {
    LoginView(didCompleteLogin: {
    })
}
