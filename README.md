# Healthy-Recipe-App
Development process of my first iOS application

## Table of Contents: 

1. [Planning](#planning) 
2. [Design](#design)
3. [Development](#development)
4. [Funcitonality](#functionality)
5. [Evaluation](#evaluation)

## Planning

### Situation Analysis

My clients are my mother and my grandmother, and they are currently facing a problem of having to think of what to cook for meals. In the current situation of the COVID-19 pandemic, everyone in their family members now stay in their houses for the whole day. Therefore, they need to cook three meals every day, for all of their family members. In June, 2020 I received a text from my mother on behalf of her and my grandmother (appendix A). She told me that they are in need for something that can help them to come up with different menus for every meal. They don't want to cook the same thing every day, and they are having trouble coming up with non-repetitive menus. Furthermore, they want their family to eat healthily, with balanced nutrition.

### Proposed Solution

The proposed solution to this problem is to create a software that provides an easy way for my clients to search for variety of menus, along with the ingredients, recipe and nutrition data. Both of my clients use an iPhone, however they can only  perform basic operations such as texting and seraching on the internet. Hence, the applicatoin should be designed in way that it can be used in these two simple steps:  

> 1.	Type in a keyword (eg. chicken, tomato)
> 2.	Scroll through and tap on the desired recipe to see details 

These are the only steps that are required by the users. As for the application, it will have a search bar for users to type in a keyword and the results page users can scroll down to see the search result. After the user has tapped on a specific recipe, it will present the ingredients, recipe, and nutrition data in one glance.

Another function this application should have is a system which notifies the users that the menu has been used recently, to prevent them from making a repetitive recipe unconsciously. This means the system should remember the most recent search history. The search histories will vary with different users, and to this issue, I decided to ceate a login system for each user so that the search history stays within their user page. 

## Design

### Test Plan

| Action Tested | Procedure | Expected Outcome |
|:-- |:-- |:-- |
| User can create their own account| Typing valid information (matching passwords, secure password, and no empty text fields) in the required text fields and checking and confirm a created user account in Cloud Firestore | If all the information entered in the text field is valid, a new document containing user information will be created in the Cloud Firestore |
|User can login & logout from their own account| Type in a registered email and password then tap the login button to see if it navigates to the main page | Once the login button is tapped if email and password are entered correctly, it will move to the main user page | 
| Disables the navigation button and various error message is shown whenever registration or login failed | Type in invalid information (non- matching password, insecure password, empty text fields, incorrect login information) to check if it shows error-specific messages, and disables the navigation button | It will show different error messages for each error, and disables the navigation button |
|Search results are shown after keywords are entered| Check by typing in keywords (ex. “tomato”, “chicken”) to see if the results show the corresponding recipes | It will show the corresponding search results (e.g. if chicken was entered, results should show “Chicken wing”, “Garlic Fried Chicken”, etc.) |
|Displays details of recipe when selected| Tap a random recipe from the search result to check the functionality of the navigation link, as well as the contents on the details view| When a recipe is selected, it will take the user to details view, and present information about ingredients, recipe, and nutrition facts | 
| Appearance of popup message to remind the user that the recipe has been made recently | For the sake of simplicity, tap on a same recipe from the previous test after a minute or two to check if a reminder would pop up | When the same recipe is tapped more than once within the given time (timer triggered by the first tapped), it will show a message reminding the user | 

 
## Development 

> ### Used Techniques
> 1. [Conditional Statements for showing different error messages](#conditional-statements-for-showing-different-error-messages)
> 2. [Firbase Authentication to store user information](#firbase-authentication-to-store-user-information)
> 3. [Webscraping and Error Handling for creating recipes database](#webscraping-and-error-handling-for-creating-recipes-database)
> 4. [Object Oriented Programming for displaying recipes](#object-oriented-programming-for-displaying-recipes)

### Conditional Statements for showing different error messages

When the users are registering for the first time, they will be required three personal information: username, email address, and password. In this particlar application the users are required to type in the same password for confirmation. These information must have certain credentials to ensure the correctness and security of user information. Whenever there are any insufficiency or invalid information, the program should return an error message specific to the user's error. The following is a code snippet from the function which is dedicated to this: 
```swift 
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
```

### Firbase Authentication to store user information

Firebase is a development platform for mobile applications, such as iOS and Androids. While there are many features in Firebase, I specifically used Cloud Firestore. This is a real-time database that Google provides us for free. I used this for storing user information as well as the web scraped data.

<img width="809" alt="Screen Shot 2022-11-10 at 22 09 21" src="https://user-images.githubusercontent.com/113309314/201254548-e7524aa6-a770-4cd0-b0fb-cf0ff7a36cc3.png">

The following code snippet adds the webscraped recipe details into the Firebase Realtime Database, to manage and store the retrieved information.

```swift 
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
```

### Webscraping and Error Handling for creating recipes database

Webscraping entails "scraping" through the webpages, and only capturing the necessary information. The webpage I used had a main page, and a sub-page for each recipe, and in the following code snippet it scrapes for the subpage link by looking through all of the <a> tags that can be found on the current page:

```swift 
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
                        
```
This is a very small portion of my webscraping code intended only for simple demonstration of how I implemented it. The full code can be seen in [webscrape.swift]().

### Object Oriented Programming for displaying recipes






## Functionality 

## Evaluation 
