//
//  Settings.swift
//  GymBro
//
//  Created by Александра Грицаенко on 08/04/2025.
//

import SwiftUI

struct Settings: View {
    @State var shouldShowLogOutOptions: Bool = false
    @State var shouldShowDeleteOptions: Bool = false
    @State private var showMainView = false
    @StateObject var vm = AccountModel()
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: AppThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showAboutAlert = false
    @StateObject private var notificationManager = NotificationsManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Background").ignoresSafeArea()
                BackgroundAnimation()
                VStack {
                    ZStack {
                        HStack {
                            dismissButton
                            Spacer()
                        }
                        Text("Settings")
                            .font(.system(size: 30))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TitleColor"))
                    }
                    themeForApp
                    languageSelector
                    requestNotificationButton
                    settingsButtonView(image: "person.text.rectangle.fill", name: Text("Profile"), destination: EditProfile(vm: vm))
                    SettingsButtonActionView(image: "person.crop.circle.badge.questionmark.fill",  name: Text("About"),
                                             action: { showAboutAlert.toggle() })
                    SettingsButtonActionView(image: "person.crop.circle.fill.badge.minus",  name: Text("Log out"),
                                             action: { shouldShowLogOutOptions.toggle() })
                    SettingsButtonActionView(image: "person.crop.circle.fill.badge.xmark",  name: Text("Delete account"),
                                             action: { shouldShowDeleteOptions.toggle() })
                    Spacer()
                }
            }
            .alert(isPresented: $showAboutAlert) {
                Alert(
                    title: Text("About GymBro"),
                    message: Text("This app helps you manage your workouts and share success with your friends. \n\nCreated by Gritsaenko Alexandra and Polyakov Stepan — the legendary duo you didn’t know you needed. Probably stronger than your will to skip leg day! \n\nComing soon to a gym near you."),
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
            .confirmationDialog(Text("Are you sure you want to delete your account?"), isPresented: $shouldShowDeleteOptions, titleVisibility: .visible) {
                Button("Delete account", role: .destructive) {
                    print("handle delete")
                    vm.handleDeleteAccount()
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
    
    private var requestNotificationButton: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "bell.badge")
                    .font(.system(size: 30))
                    .foregroundColor(Color("TitleColor"))
                    .padding(.leading, 20)
                Text("Notifications")
            }
            HStack {
                Spacer()
                Button(action: {
                    Task {
                        await notificationManager.request()
                    }
                }) {
                    Text(notificationManager.hasPermission ? "Notification Permission Granted" : "Request Notification Permission")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 18)
                        .background(notificationManager.hasPermission ? Color("TabBar") : Color("PurpleColor"))
                        .foregroundColor(notificationManager.hasPermission ? .gray : .white)
                        .clipShape(Capsule())
                        .overlay(Capsule()
                            .stroke(Color("PurpleColor"), lineWidth: 2))
                }
                .disabled(notificationManager.hasPermission)
                .task {
                    await notificationManager.getAuthStatus()
                }
                Spacer()
            }
            Divider()
        }
        .padding(.horizontal, 10)
    }
    
    private var dismissButton: some View {
        Button(action: {
            dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color("TitleColor"))
                    .font(.system(size: 30))
                    .padding(.trailing, -10)
                Text("Cancel")
                    .foregroundColor(Color("TitleColor"))
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
    
    private var languageSelector: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "globe")
                    .font(.system(size: 30))
                    .foregroundColor(Color("TitleColor"))
                    .padding(.leading, 20)
                Text("Choose language")
            }
            HStack(spacing: 12) {
                Spacer()
                ForEach(["en", "ru"], id: \.self) { lang in
                    Button {
                        languageManager.selectedLanguage = lang
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            exit(0)
                        }
                    } label: {
                        Text(lang.uppercased())
                            .padding(.vertical, 8)
                            .padding(.horizontal, 18)
                            .background(languageManager.selectedLanguage == lang ? Color("PurpleColor") : Color("TabBar"))
                            .foregroundColor(languageManager.selectedLanguage == lang ? .white : .gray)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color("PurpleColor"), lineWidth: 2))
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

class LanguageManager: ObservableObject {
    @AppStorage("selectedLanguage") var selectedLanguage: String = Locale.current.languageCode ?? "en" {
        didSet { setLanguage(selectedLanguage) }
    }
    
    init() {
        setLanguage(selectedLanguage)
    }

    private func setLanguage(_ lang: String) {
        UserDefaults.standard.set([lang], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
}

#Preview {
    Settings().environmentObject(AppThemeManager())
              .environmentObject(LanguageManager())
}
