//
//  Webscraping.swift
//  ComputerScienceIA
//
//  Created by Arata Michael Katayama on 2021/01/04.
//

import SwiftUI
import Firebase
import SwiftSoup

struct WebscrapeView: View {
    
    // creating global variables for necessary html tags
    @State var basehtml = ""
    @State var subhtml = ""
    
    @State var recipeLinks: [String] = [] 
    
    @State var recipeNames: [String] = []
    @State var recipeImageLinks: [String] = []
    @State var recipeDescs: [String] = []  // description info 
    @State var recipeNutDict: [String: [String]] = [:]  // nutrition info 
    @State var recipeIngredDict: [String: [String]] = [:]  // ingred info 

    // linking to Firebase
    func addToFirestore() {
        
        accessSubURL()
        
        // creating a constant for the database
        let db = Firestore.firestore()
        
        // loop through the number of links retrieved to create the correct number of documents
        // add all information to firestore
        for i in 0..<recipeLinks.count {
            db.collection("recipeData").addDocument(data: ["name": recipeNames[i], "info": recipeDescs[i], "image": recipeImageLinks[i], "ingred": recipeIngredDict[recipeNames[i]], "nutrit": recipeNutDict[recipeNames[i]]])
        }
    
    }
    
    // function that extracts every recipe link from the main page of the website
    func extractLink() {
        
        // looping through many pages
        for n in 0...100{
            
            // receive the base url
            let baseurl = "https://www.allrecipes.com/recipes/1947/everyday-cooking/quick-and-easy/?page=\(n)"
            
            guard let myURL = URL(string: baseurl) else {
                print("Error: \(baseurl) doesn't seem to be a valid URL")  // if url is invalid (message only for developer)
                return
            }
            
            // error handling
            do {
                // retrieving html of the baseurl and storing it to basehtml
                let htmlString = try String(contentsOf: myURL, encoding: .ascii)
                basehtml = htmlString
                
                // retreive the html tag that contains the link
                do {
                    // parsing html using SwiftSoup
                    let doc: Document = try SwiftSoup.parse(basehtml)
                    // select the tag that contains the link and put it in an array
                    let a: [Element] = try doc.select("a").array()
                    // for each "a" check the classname
                    for i in 0..<a.count {
                        // get classname
                        let className: String = try a[i].className()
                        // <a> with classname of the below containes recipe links
                        // append the links contained in a into the recipeLinks
                        if className == "tout__titleLink" {
                            // add to recipeLinks
                            recipeLinks.append(try "https://www.allrecipes.com/\(a[i].attr("href"))")
                        }
                    }
                    
                // error handling 
                } catch Exception.Error(type: let type, Message: let message) {
                    print(type)
                    print(message)
                } catch {
                    print("")
                }
            // error handling 
            } catch let error {
                print(error)
            }
        }
    }
    
    // retrieving subhtml for suburl
    func accessSubURL() {
        
        // create arrays of arrays to store all ingredients and nutrition information
        var ingredForAllRecipe: [[String]] = []
        var nutritForAllRecipe: [[String]] = []
        
        // call function to have a completed recipeLinks list
        extractLink()
        
        // loop through the retrieved links from the main page
        for link in recipeLinks {

            let suburl = link

            // check if the url exists or not
            guard let myURL = URL(string: suburl) else {
                print("Error: \(suburl) doesn't seem to be a valid URL")
                return
            }
                        
            do {
                // retrieve the html code of the suburl
                let htmlString = try String(contentsOf: myURL, encoding: .ascii)
                subhtml = htmlString
                // call the functions to fill the data lists
                getName()
                getDesc()
                getImage()

                // retrieving information for ingredients and nutritions
                do {
                    // create an array for ingredients for single recipe
                    var ingredForSpecificRecipe: [String] = []
                    // parsing html using SwiftSoup
                    let doc: Document = try SwiftSoup.parse(subhtml)
                    // select the tag that contains the link and put it in an array
                    let span: [Element] = try doc.select("span").array()
                    // for each "span" check the classname
                    for ind in 0..<span.count {
                        let className: String = try span[ind].className()
                        // span with classname of the below containes recipe ingredients
                        if className == "ingredients-item-name" {
                            let recipeIngred: String = try span[ind].text()
                            // append each text of the span into the ingredForSpecificRecipe
                            ingredForSpecificRecipe.append(recipeIngred)
                        }
                    }
                    
                    // append single recipe ingred arrays to array a bigger array
                    ingredForAllRecipe.append(ingredForSpecificRecipe)
                
                    
                } catch Exception.Error(type: let type, Message: let message) {
                    print(type)
                    print(message)
                } catch {
                    print("")
                }
                
                do {
                    // create an array for nutritions for single recipe
                    var nutText: [String] = []
                    let doc: Document = try SwiftSoup.parse(subhtml)
                    // select the tag that contains the link and put it in an array
                    let div: [Element] = try doc.select("div").array()
                    // for each "fiv" check the classname
                    for i in 0..<div.count {
                        // get classname
                        let className: String = try div[i].className()
                        // div with classname of the below containes nutrition information
                        if className == "section-body" {
                            let recipeNut: String = try div[i].text()
                            nutText.append(recipeNut)
                        }
                    }
                    nutritForAllRecipe.append(nutText)
                
                } catch Exception.Error(type: let type, Message: let message) {
                    print(type)
                    print(message)
                } catch {
                    print("")
                }
            
            } catch let error {
                print(error)
            }

        }

        // fill in the dictionaries for ingredients and nutritions
        for i in 0..<recipeNames.count {
            recipeIngredDict[recipeNames[i]] = ingredForAllRecipe[i]
            recipeNutDict[recipeNames[i]] = nutritForAllRecipe[i]
        }

        
    }
        
    // retirieving recipe names
    func getName() {

        // do catch statement to retreive the html tag that contains that recipe names
        do {
            // parsing html using SwiftSoup
            let doc: Document = try SwiftSoup.parse(subhtml)
            // select the tag that contains the recipe names and put it in an array
            let h1: [Element] = try doc.select("h1").array()
            // for each "h1" check the classname
            for i in 0..<h1.count {
                let className: String = try h1[i].className()
                // <h1> with classname of the below containes recipe name
                // append the text of <h1> into the nameArray
                if className == "headline heading-content" {
                    let recipeName: String = try h1[i].text()
                    recipeNames.append(recipeName)
                }
            }

        } catch Exception.Error(type: let type, Message: let message) {
            print(type)
            print(message)
        } catch {
            print("")
        }

    }
    
    // retrieve descriptions of the recipe
    func getDesc() {
        
        // do catch statement to retreive the html tag that contains the link
        do {
            // parsing html using SwiftSoup
            let doc: Document = try SwiftSoup.parse(subhtml)
            // select the tag that contains the link and put it in an array
            let p: [Element] = try doc.select("p").array()
            // for each "p" check the classname
            for i in 0..<p.count {
                let className: String = try p[i].className()
                // "p" with classname of the below containes recipe name
                // append the text of the "p" into the nameArray
                if className == "margin-0-auto" {
                    let recipeDesc: String = try p[i].text()
                    recipeDescs.append(recipeDesc)
                }
            }
            
        } catch Exception.Error(type: let type, Message: let message) {
            print(type)
            print(message)
        } catch {
            print("")
        }
        
    }
    
    func getImage() {
        
        // do catch statement to retreive the html tag that contains the link
        do {
            // parsing html using SwiftSoup
            let doc: Document = try SwiftSoup.parse(subhtml)
            let div: [Element] = try doc.select("div").array()
            // create empty array for image tags
            var srcInSingleHTML: [String] = []
            // for every div detected
            for i in 0..<div.count {
                // create constant of string type containing the folloeing information of the tag
                let srcName: String = try div[i].attr("data-src")
                // check if source name contains the following string
                if srcName.contains("https://imagesvc.meredithcorp.io/v3/mm/image?url=https%3A%2F%2Fimages.media-allrecipes.com%2Fuserphotos%2") {
                    // fill the empty array
                    srcInSingleHTML.append(srcName)
                }
            }
            // get the second element of srcInSingleHTML which is the image link to the recipe
            recipeImageLinks.append(srcInSingleHTML[1])

        } catch Exception.Error(type: let type, Message: let message) {
            print(type)
            print(message)
        } catch {
            print("")
        }

    }

    // not part of the application view (only for the creator)
    var body: some View {
        VStack {
            HStack{
                Button(action: {
                    // call function to retrieve all desired data and add to firebase
                    addToFirestore()
                }) {
                    // confirm with the developer side that the data has been added to Cloud Firestore successfully
                    Text("add data!")
                }
            }
        }
        
        
    }
}

struct Webscraping_Previews: PreviewProvider {
    static var previews: some View {
        WebscrapeView()
    }
}
