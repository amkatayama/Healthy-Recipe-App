//
//  HomescreenView.swift
//  ComputerScienceIA
//
//  Created by Arata Michael Katayama on 2021/01/04.
//

import SwiftUI
import Firebase

// create the main search page
struct ContentView: View {
    
    @ObservedObject var data = getData()

    var body: some View {
        
        NavigationView {
            
            ZStack(alignment: .top) {
                
                GeometryReader{_ in
            
                }.background(Color("Color").edgesIgnoringSafeArea(.all))
                
                CustomSearchBar(data: self.$data.datas)
                    .frame(height: UIScreen.main.bounds.height/1.2, alignment: .top)
                    .navigationBarHidden(true)
                
                VStack(alignment: .trailing) {
                    
                    Spacer()
                    
                    // log out button
                    NavigationLink(destination: LoginView()) {
                        
                        Text("Log out")
                            .font(.system(size: 12, weight: .regular))
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(40)
                            .foregroundColor(.white)
                            .padding(10)
                        
                    }
                    
                }
                
            }
            
        }
        // hide navigation bar
        .navigationBarTitle("")
        .navigationBarHidden(true)
        
    }
}
// allows to show images with url
import Kingfisher

struct CustomSearchBar: View {
            
    @State var searchText = ""
    @Binding var data: [Recipe]
        
    var body: some View {
        
        VStack {
            HStack {
                // creating textfield for keywords
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search recipe", text: $searchText)
                
                // is user enters a keyword
                if self.searchText != "" {
                
                    // create cancel button which resets the textfield
                    Button(action: {
                        // delete keyword
                        self.searchText = ""
                        
                    }) {
                        Text("Cancel")
                            .foregroundColor(.gray)
                    }
                    .foregroundColor(.black)
                }
            }
            .padding(.all, 20)
            .background(Color(.systemGray4))
            .cornerRadius(8)
            .padding(.horizontal, 20)
                    
            // if user input is not nil
            if self.searchText != "" {
                
                // if there is no correspondence between the entered information and the recipe names stored in database
                if self.data.filter({$0.name.lowercased().contains(self.searchText.lowercased())}).count == 0 {
                    
                    // show message to user
                    Text("No Results Found").foregroundColor(Color.black.opacity(0.5))
                    
                } else {
                                       
                    // create navigation view
                    NavigationView {
                        
                        // if there is a correspondence
                        List (self.data.filter{$0.name.lowercased().contains(self.searchText.lowercased())}) {recipes in
                            
                            // show view
                            RecipeView(recipeItem: recipes).navigationBarHidden(true)
                                            
                        }
                        
                    }
                    
                }
                    
            }
            
        }.background(Color.white)
        .padding()
        
            
    }
    
}                

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// create class getData
class getData: ObservableObject {
    
    // passing attribute
    @Published var datas = [Recipe]()

    // creating initializing method
    init() {
        let db = Firestore.firestore()

        // get all documents from "recipeData"
        db.collection("recipeData").getDocuments {(snap, err) in

            // if error is returned notify
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }

            // for every documents in the database
            for i in snap!.documents {
                // reading all fields in document from firestore and storing it in a constant
                let id = i.documentID
                let name = i.get("name") as! String // data type specification
                let info = i.get("info") as! String
                let image = i.get("image") as! String
                let ingred = i.get("ingred") as! [String]
                let nutrit = i.get("nutrit") as! [String]

                // store them into the variable "datas" and this can be passed to other objects
                self.datas.append(Recipe(id: id, name: name, info: info, image: image, ingred: ingred, nutrit: nutrit))

            }

        }
    }
}

// assigning variables and their data type
struct Recipe : Identifiable {
    var id: String
    var name: String
    var info: String
    var image: String
    var ingred: [String]
    var nutrit: [String]
}
