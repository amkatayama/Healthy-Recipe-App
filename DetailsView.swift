//
//  DetailsView.swift
//  ComputerScienceIA
//
//  Created by Arata Michael Katayama on 2021/01/17.
//

import SwiftUI
import Firebase
import Kingfisher

struct DetailsView: View {
    let recipeItem: Recipe
    
    var body: some View {
        
        VStack(spacing: 10) {
        
            KFImage(URL(string: recipeItem.image))
                .resizable()
                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                .frame(width: 350, height: 150)
                .clipped()
                .cornerRadius(6)
            
            Text(recipeItem.name)
                .font(.system(size: 20, weight: .semibold))

            Text(recipeItem.info)
                .font(.system(size: 12, weight: .regular))
            
            Text("Ingredients")
                .font(.system(size: 15, weight: .semibold))

            List (0..<recipeItem.ingred.count) { i in
                
                Text(recipeItem.ingred[i])
                    .font(.system(size: 12, weight: .regular))

            }
            
            Text("How to cook & Nutritions")
                .font(.system(size: 15, weight: .semibold))
            
            // creating a dynamic list
            List (0..<(recipeItem.nutrit.count)) { i in
                
                Text(recipeItem.nutrit[i])
                    .font(.system(size: 12, weight: .regular))
                
            }
        
        }
    }
}

struct RecipeView: View {
    
    @State var timer: Timer? = nil
    @State var isTimerRunning = false
    @State var showingConfirmAlert = false
    @State var navigate = false
    
    @State var clickCount = 0
    
    let recipeItem: Recipe
    
    var body: some View {
        
        NavigationLink(destination: DetailsView(recipeItem: recipeItem), isActive: .constant(navigate == true)) {
            
            // Image of recipes
            KFImage(URL(string: recipeItem.image))
                .resizable()
                .scaledToFit()
                .cornerRadius(22)
            
            HStack {
                VStack (alignment: .leading, spacing: 4) {
                    
                    Text(recipeItem.name)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.black)
                    
                    Text(recipeItem.info)
                        .font(.system(size: 12, weight: .regular))
                    
                }

                Spacer()
            }
            
        }
        // perform action when navigation link is tapped
        .simultaneousGesture(TapGesture().onEnded{
            // default to true when button is tapped
            navigate = true
            // restart timer whenever the button is tapped
            startTimer()
            // increase click count by one as the button is tapped
            clickCount += 1
            print(clickCount)
            

            // if timer is running and clickcount is bigger than 1
            if timer != nil && clickCount > 1 {
                // don't enable navigation link
                navigate = false
                showingConfirmAlert = true
            } else {
                // explicitly set navigate to true so that after the timer stops all
                navigate = true
            }
        
        })
        
        // only if showingCofirmAlert is true show the alert message
        .alert(isPresented: $showingConfirmAlert) {
            Alert(title: Text("Continue?"), message: Text("You have checked this recipe out within the last 24 hours. Do you still want to continue?"), primaryButton: .default(Text("Yes"), action: {navigate = true}), secondaryButton: .cancel(Text("No"), action: {navigate = false}))
        }
    }

    func startTimer() {
        // creating a timer which runs for 24hours and stops
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { timer in
            // reset clickCount to 0 every 24 hours
            clickCount = 0
            print(clickCount)
        }
    }
    
}
