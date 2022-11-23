//
//  SignupView.swift
//  ComputerScienceIA
//
//  Created by Arata Michael Katayama on 2020/11/20.
//

import SwiftUI
import FirebaseAuth
import Firebase

// creating registration view
struct SignupView: View {
    
    // creating necessary variables
    @State var username_su = ""
    @State var email_su = ""
    @State var password_su = ""
    @State var confirmPassword = ""
    @State var errorMessage = ""
    @State var signuppage = false
    @State var authenticationSucceed_su: Bool = false
    @State var navigate: Bool = false

    
    // check if all the fields contain the correct information
    // show different errors messages for different errors 
    func validateFields() -> String? {
        
        // check if all the fields are filled
        if self.username_su.count == 0 || self.email_su.count == 0 || self.password_su.count == 0 || self.confirmPassword.count == 0 {
            
            errorMessage = "Please fill in all fields"
            return "error"

        }
        // check if the password is secure
        if isPasswordSecure(password_su) == false {
            
            // show error message
            errorMessage = "Please make sure you password includes at least one uppercase, one lowercase, one numeric digit and is more than 8 characters."
            return "error"
        }
        
        // check if the password and confirmed password match
        if self.confirmPassword != self.password_su {
            
            errorMessage = "Please make sure that your passwords match."
            return "error"
            
        }
        
        // if no error is detected return nil (default setting of return value)
        return nil
        
    }
    
    // checking if the password is secure enough
    func isPasswordSecure(_ password: String) -> Bool {
        
        // setting a format for the password
        // password should have: at least one uppercase and a lowercase, at leat one number, and 8 characters long
        let passwordFormat = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}")
        
        // return true or false depending on whether password follows the format or not
        return passwordFormat.evaluate(with: password)
    }

    var body: some View {
        
        NavigationView {
            
            VStack (spacing: 30){
                
                Spacer()
                
                // Creating a title for the page
                Text("Create an account")
                    .padding(.all, 20)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.yellow)
                    .background(Color.gray.opacity(0.9))
                    .cornerRadius(8)
                    .padding(.horizontal, 20)
                
                // Text field for username 
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(.gray)
                    TextField("Username", text: $username_su)
                }
                .padding(.all, 20)
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal, 20)
                
                // Text field for email address
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.gray)
                    TextField("Email address", text: $email_su)
                }
                .padding(.all, 20)
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal, 20)
                
                // Text field for the password
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.gray)
                    SecureField("Password", text: $password_su)
                }
                .padding(.all, 20)
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal, 20)
                
                // Text field for the user to re-enter the password for confirmation
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.gray)
                    SecureField("Re-enter your password", text: $confirmPassword)
                }
                .padding(.all, 20)
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal, 20)
                
                // if all information is valid
                if authenticationSucceed_su {
                    Text("Success!")
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(8)
                        .foregroundColor(.black)
                        .padding(.top, 30)
                } else {
                    // showing different error messages for different errors
                    Text(errorMessage)
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(8)
                        .foregroundColor(.red)
                        .padding(.top, 30)
                }
                
                
                // create navigation link which only works when authenticationSucceed_su = true
                NavigationLink(destination: ContentView(), isActive: .constant(self.authenticationSucceed_su == true)) {
                    Text("Create Account")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .medium))
                }.navigationBarTitle("")
                .navigationBarHidden(true)
                .frame(maxWidth: .infinity)
                .padding(.all, 20)
                .background(Color.blue.opacity(0.8))
                .cornerRadius(8)
                .padding(.horizontal, 20)
                // call function at the same time the button is tapped
                .simultaneousGesture(TapGesture().onEnded{
                    checkLoginInfo()
                })
                
                // creating back button
                NavigationLink(destination: LoginView()) {
                    Text("Bo back to Login")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .medium))
                }.frame(maxWidth: .infinity)
                .padding(.all, 20)
                .background(Color.yellow.opacity(0.8))
                .cornerRadius(8)
                .padding(.horizontal, 20)
                
                Spacer()
                
            }.background(
                Image("kitchen")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            ).edgesIgnoringSafeArea(.all)
        }
        .navigationBarHidden(true)
    }
    
    func checkLoginInfo() {
        // validate the fields
        let error = validateFields()
        
        // if the return value of validateFields() is "error"
        if error != nil {
            
            // If error in fields show error message
            self.authenticationSucceed_su = false
          
        // otherwise if nil
        } else {
            
            // show message to show that sign up was successful
            self.authenticationSucceed_su = true
            
            // store the most recent input from the user
            let username = self.username_su
            let email = self.email_su
            let password = self.password_su
            
            // create the user accordingly to the registerd information
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                // Check for errors
                if err != nil {
                    // error found in creating user
                    print("Error creating user")
                } else {

                    // user was created successfully
                    // storing database into a constant
                    let db = Firestore.firestore()
                    
                    // find collection called "users" and create a new docuemnt with their user id
                    db.collection("users").addDocument(data: ["username":username, "uid":result!.user.uid]) { (error) in
                        
                        // check for errors
                        if error != nil {
                            print("Error saving user data")
                        }
                    }
                    
                    // empty the textfields
                    username_su = ""
                    email_su = ""
                    password_su = ""
                    confirmPassword = ""
            
                }
            }
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
