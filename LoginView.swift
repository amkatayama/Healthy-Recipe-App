//
//  ContentView.swift
//  ComputerScienceIA
//
//  Created by Arata Michael Katayama on 2020/11/20.
//

import SwiftUI
import Firebase
import FirebaseAuth

// creating login view
struct LoginView: View {
            
    // creating variables 
    @State var email_li = ""
    @State var password_li = ""
    @State var errorMessage = ""
    @State var authenticationSucceed_li: Bool = false
    @State var isNavigationBarHidden: Bool = true
    @State var loginButtonTapped: Bool = false
    
    // return function checking if the user input information can be found in firebase
    func verifyLogin(email: String, password: String) -> Bool {
        // Checking the firebase if the entered login information matches the registered
        Auth.auth().signIn(withEmail: email, password: password) {(result, error) in

            // if no error
            if error != nil {
                // Couldn't sign in
                errorMessage = "Wrong email address or password. Please try again."
                self.authenticationSucceed_li = false
            } else {
                // else if error == nil
                self.authenticationSucceed_li = true
            }
        }
        
        // returning a bool
        if self.authenticationSucceed_li == true {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        
        NavigationView {
            
            // Vertical Stack
            VStack(spacing: 15) {
                
                Spacer()
                
                // Title of the page
                Text("Welcome")
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundColor(.yellow)
                
                // creating text field for email address
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.gray)
                    TextField("Email address", text: $email_li)
                }
                .padding(.all, 20)
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal, 20)
                
                // craeting text field for password
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.gray)
                    SecureField("Password", text: $password_li)
                }
                .padding(.all, 20)
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal, 20)
                
                if authenticationSucceed_li {
                    // show the following if login success
                    Text("Login Success!")
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(8)
                        .foregroundColor(.black)
                        .padding(.top, 30)
                } else {
                    // show the following if login fail
                    Text(errorMessage)
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(8)
                        .foregroundColor(.red)
                        .padding(.top, 30)
                }
                
                // navigation link navigated to homescreen only when both of the entered information is true
                NavigationLink(destination: ContentView(), isActive: .constant(self.authenticationSucceed_li == true)) {
                    Text("Login")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .medium))
                }.navigationBarTitle("Logout")
                .frame(maxWidtLoginViewh: .infinity)
                .padding(.all, 20)
                .background(Color.blue.opacity(0.8))
                .cornerRadius(8)
                .padding(.horizontal, 20)
                // perform action when navigation link is tapped
                .simultaneousGesture(TapGesture().onEnded{
                    if verifyLogin(email: email_li, password: password_li) == true {
                        // if the login information is valid show the success message
                        self.authenticationSucceed_li = true
                    } else {
                        // if the login information is invalid show error meessage
                        self.authenticationSucceed_li = false
                    }
                    // reset textfield
                    self.email_li = ""
                    self.password_li = ""
                })

                // Text inidicating that the create account button is only for first time users
                Text("For first time users")
                    .padding(.top, 130)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
               
                // Create account button
                NavigationLink(destination: SignupView()) {
                    Text("Create Account")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                        .padding(.vertical, 10)
                        .background(Color.yellow.opacity(0.8))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                }
                // delete the navigation bar
                .navigationBarHidden(self.isNavigationBarHidden)
                .onAppear {
                   self.isNavigationBarHidden = true
               }

                Spacer()
                
            }.background(
                // set background image
                Image("kitchen")
                    .resizable()
                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
            ).edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
        // hide all gaps created by navigation bar to organize the page
        }.navigationBarHidden(true)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
        SignupView()
    }
}
