//
//  Settings.swift
//  GymBro
//
//  Created by Александра Грицаенко on 08/04/2025.
//

import SwiftUI

struct Settings: View {
    @State var shouldShowLogOutOptions: Bool = false
    @State private var showMainView = false
    @StateObject var vm = AccountModel()
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: AppThemeManager
    @State private var showAboutAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Background").ignoresSafeArea()
                BackgroundAnimation()
                VStack {
                    HStack {
                        dismissButton
                        Text("Settings")
                            .font(.system(size: 30))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TitleColor"))
                            .padding(.leading, 50)
                        Spacer()
                    }
                    themeForApp
                    // language
                    settingsButtonView(image: "person.text.rectangle.fill", name: Text("Profile"), destination: EditProfile())
                    // reminders ???????
                    SettingsButtonActionView(image: "person.crop.circle.badge.questionmark.fill",  name: Text("About"),
                                             action: { showAboutAlert.toggle() })
                    SettingsButtonActionView(image: "person.crop.circle.fill.badge.minus",  name: Text("Log out"),
                                             action: { shouldShowLogOutOptions.toggle() })
                    SettingsButtonActionView(image: "person.crop.circle.fill.badge.xmark",  name: Text("Delete account"),
                                             action: { print("should delete account") })
                    Spacer()
                }
            }
            .alert(isPresented: $showAboutAlert) {
                Alert(
                    title: Text("About GymBro"),
                    message: Text("This app helps you manage your workouts and share success with your friends. \n\n Created by Gritsaenko Alexandra and Polyakov Stepan — the legendary duo you didn’t know you needed. Probably stronger than your will to skip leg day! \n\n Coming soon to a gym near you."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .confirmationDialog(Text("Are you sure you want to log out?"), isPresented: $shouldShowLogOutOptions, titleVisibility: .visible) {
                Button("Log out", role: .destructive) {
                    print("handle log out")
                    vm.handleSignOut()
                    showMainView = false
                }
                Button("Cancel", role: .cancel) {}
            }
            .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut) {
                LoginView(didCompleteLogin: {
                    self.vm.isUserCurrentlyLoggedOut = false
                    self.vm.fetchCurrentUser()
                    self.showMainView = true
                })
            }
            .fullScreenCover(isPresented: $showMainView) {
                MainView()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var dismissButton: some View {
        Button(action: {
            dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color(.label))
                    .font(.system(size: 30))
                Text("Back")
                    .foregroundColor(Color(.label))
                    .font(.system(size: 20))
            }
            .padding(.leading, 10)
        }
    }
    
    func themeLabel(for theme: ColorScheme?) -> String {
        switch theme {
        case .light: return "Light"
        case .dark: return "Dark"
        default: return "System"
        }
    }
    
    private var themeForApp: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "moonphase.waning.crescent")
                    .font(.system(size: 30))
                    .foregroundColor(Color("TitleColor"))
                    .padding(.leading, 20)
                Text("Choose theme for GymBro")
            }
            HStack(spacing: 12) {
                Spacer()
                ForEach([nil, ColorScheme.light, ColorScheme.dark], id: \.self) { theme in
                    Button {
                        themeManager.selectedTheme = theme
                    } label: {
                        Text(themeLabel(for: theme))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 18)
                            .background(themeManager.selectedTheme == theme ? Color("PurpleColor") : Color("TabBar"))
                            .foregroundColor(themeManager.selectedTheme == theme ? .white : .gray)
                            .clipShape(Capsule())
                            .overlay(Capsule()
                                .stroke(Color("PurpleColor"), lineWidth: 2))
                    }
                }
                Spacer()
            }
            Divider()
        }
        .padding(.horizontal, 10)
    }
}

class AppThemeManager: ObservableObject {
    @AppStorage("selectedTheme") private var storedTheme: String = "system"
    
    @Published var selectedTheme: ColorScheme? {
        didSet {
            switch selectedTheme {
            case .light: storedTheme = "light"
            case .dark: storedTheme = "dark"
            default: storedTheme = "system"
            }
        }
    }
    
    init() {
        switch storedTheme {
        case "light": selectedTheme = .light
        case "dark": selectedTheme = .dark
        default: selectedTheme = nil
        }
    }
}



#Preview {
    Settings().environmentObject(AppThemeManager())
}
