// Coding samples from my Voca+ vocabulary-reference iOS app. 
// These segments handle the user input (a word), which they want to look up in the Oxford dictionary.
// I implemented the user interface in UIKit and Interface Builder, the API call, parsing the JSON data and integrating it into the view.

// This function handles the behavior of the look-up button and calling the API.
@IBAction func lookUp(_ sender: UIButton) {
        
    // Boolean variable determines whether or not the API call should be triggered depending on whether the word inputed by the user already exists in the database or not. 
    let triggerAPICall = triggerOrDismissAPICall(duplicate: duplicateMatch())
    
    // Checks internet connection before calling the API.
    if triggerAPICall == true {
        if NetworkMonitor.shared.isConnected {
            reworkedmakeGetCall()
        }
        else {
            noInternetConnectionAlert()
        }
    }
}

// Triggers the API call if the word inputed by the user doesn't already exist in the database.
func triggerOrDismissAPICall (duplicate: Bool) -> Bool {
    if duplicate == true {
        print("Error: duplicate entry.")
        return false
    }
    else if duplicate == false {
        if wordIdWasInputed() == false {
            return false
        }
        print("This word is not a duplicate, proceed to API call...")
        return true
    }
    return false
}
    
// This function sanitizes the user input and returns the word_id that will be used to make the API call
func sanitizedWordId() -> (String) {
    let userInput = inputField.text!

    // Sanitize the user input: remove special characters and white spaces
    let sanitizedUserInput = userInput.folding(options: .diacriticInsensitive, locale: .current).filter {!$0.isWhitespace}
    
    // Assign the sanitized user input to a new variable and lowercase it
    let word_id = sanitizedUserInput.lowercased()
        
    return word_id
}

// This function checks whether the entry is a duplicate or not. 
func duplicateMatch() -> Bool {
    let userInput = inputField.text!
    let sanitizedUserInput = userInput.folding(options: .diacriticInsensitive, locale: .current).filter {!$0.isWhitespace}
    let word_id = sanitizedUserInput.lowercased()

    // Run the duplicate check in database: the entry is a duplicate if there already exists one or more rows (or entries) where the contents are equal to the inputed word id
    let isDuplicate = Words.main.checkDuplicateWords(inputedWord: "\(word_id)")
        
    // If there already exists an entry, and isDuplicate is greater than 0, the entry is a duplicate
    if isDuplicate > 0 {
        print("This entry is a duplicate:", isDuplicate)
        return true
    }
    
    // Else if no records are associated with the contents inputed by the user, the entry is not a duplicate and the app can run the UI updates
    else if isDuplicate == 0 {
        print("This entry is not a duplicate:", isDuplicate)
        print("Proceed to looking up the word in the Oxford Dictionary and makeAPICall to the API.")
        return false
    }

    return false
}

// This function handles the Oxford English Dictionary API call. It accesses the relevant API endpoints, parse the returned JSON data, displays it onto the user interface and saves data to the database.
func APICall() {
        
    let word_id = sanitizedWordId()
    let strictMatch = "false"
    
    let url = URL(string: "https://od-api.oxforddictionaries.com:443/api/v2/entries/\(language)/\(word_id)?strictMatch=\(strictMatch)")!
        
    // Variables containing UI elements
    var text: [String] = []
    var searchWordLexicalEntry = String() // word to display in UI
    var searchWordLexicalCategory = String() // word category
    var wordDefArray: [String] = []
    var wordDefPrintArray: [String] = []
    var wordSubsensesArray: [String] = []
    var wordSubsensesPrintArray: [String] = []
        
    var request = URLRequest(url: url)
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue(appId, forHTTPHeaderField: "app_id")
    request.addValue(appKey, forHTTPHeaderField: "app_key")
        
    let session = URLSession.shared
    _ = session.dataTask(with: request, completionHandler: { data, response, error in
        if let response = response,
            let data = data,
            let jsonDataString = String(data:data, encoding: .utf8)!.data(using: .utf8)
            {
                if let httpResponse = response as? HTTPURLResponse {
                    // MARK: Http Response Class status codes
                    var responseStatusCode = httpResponse.statusCode
                    
                    // MARK: Determine whether the Http status code is successful (200) or it returns an error
                    let httpResponseContainsError = self.httpResponseError(responseStatusCode: responseStatusCode)
                    
                    // If Http response status code contains error
                    if httpResponseContainsError == true {
                        // MARK: Warn user that there is an error and prompt user to try again
                            DispatchQueue.global(qos: .background).async {

                                // Background Thread

                                DispatchQueue.main.async {
                                    // Run UI Updates
                                    self.createAlert(title: "No match found", message: "Please try again.")
                                }
                            }
                        }
                        
                    else {
                        // JSON Data Parser
                        do {
                            let response = try JSONDecoder().decode(Response.self, from: jsonDataString)
                            var index = 0
                                
                            if response.results != nil {
                                for result in response.results! {
                                    for lexicalentry in result.lexicalEntries {
       
                                        searchWordLexicalCategory = lexicalentry.lexicalCategory.text
                                        wordDefArray.append(searchWordLexicalCategory)
                                        
                                            
                                        if lexicalentry.derivativeOf != nil {
                                            for arrayofrelatedentries in lexicalentry.derivativeOf! {
                                                if arrayofrelatedentries.text != nil {
                                                    wordDefArray.append("Derivative of: \(arrayofrelatedentries.text!)")
                                                }
                                            }
                                        }
                                            
                                        if lexicalentry.entries != nil {
                                            for entry in lexicalentry.entries! {
                                                if entry.grammaticalFeatures != nil {
                                                    for grammaticalfeature in entry.grammaticalFeatures! {
                                                        if grammaticalfeature.text != nil {
                                                            wordDefArray.append("\(grammaticalfeature.text)")
                                                        }
                                                    }
                                                }
                                                    
                                                if entry.senses != nil {
                                                    for sense in entry.senses! {
                                                        if sense.definitions != nil {
                                                            index+=1
                                                                
                                                            // Add definition index (1. , 2. ...) only if there is more than one definition
                                                            if sense.definitions!.count > 1 {
                                                                wordDefArray.append("\(index). \(sense.definitions!.joined(separator: ""))")
                                                                print("\(index). \(sense.definitions!.joined(separator: ""))")
                                                            }
                                                            else {
                                                                wordDefArray.append("\(sense.definitions!.joined(separator: ""))")
                                                                print("\(sense.definitions!.joined(separator: ""))")
                                                            }
                                                        }
                                                        if sense.subsenses != nil {
                                                            for definition in sense.subsenses! {
                                                                if definition.definitions != nil {
                                                                    print("- \(definition.definitions?.joined(separator: "") ?? "")")
                                                                    wordDefArray.append("- \(definition.definitions!.joined(separator: ""))")
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                if entry.etymologies != nil {
                                                    print(entry.etymologies!.joined(separator: ""))
                                                    wordDefArray.append("Origin: \(entry.etymologies!.joined(separator: ""))")
                                                }
                                            }
                                        }
                                            
                                        if lexicalentry.phrases != nil {
                                            for phrase in lexicalentry.phrases! {
                                                print(phrase.text!)
                                                wordDefArray.append("-→ \(phrase.text!)")
                                            }
                                        }
                                    }
                                }
                            }
                                
                            // Make UI Changes
                            print("searchWordLexicalEntry:", searchWordLexicalEntry)
                            print(wordDefArray)
                                
                            // MARK: Number of definitions returned by the API
                            print("Number of definitions returned by the API (wordDefArray size):", wordDefArray.count)
                            let textForUI = text.first!
                                
                            for element in wordDefArray {
                                print(element, "\n")
                                wordDefPrintArray.append("\(element)")
                            }
                                
                            let stringwordDefPrintArray = wordDefPrintArray.joined(separator: "\n\n")
                                
                            DispatchQueue.global(qos: .background).async {
                                // Background Thread
                                DispatchQueue.main.async {
                                    // Run UI Updates once definition was downloaded from API
                                    let definitionsResult = "\(textForUI)\n\n\n\(stringwordDefPrintArray)\n"
                                    // Display accents
                                    self.textView.text = "\(textForUI)"
                                    self.wordefView.text = "\(stringwordDefPrintArray)"
                                        
                                    //Save word to Database
                                    self.word.contents = self.textView.text
                                    WordManager.main.save(word: self.word)

                                }
                            }
                            } catch {
                                print(error.localizedDescription)
                                print(String(describing: error))
                            
                                // MARK: Handles no internet connection and displays an error message to the user
                                // SRC: https://stackoverflow.com/questions/29122066/nsurlsession-error-handling
                                if let error = error as NSError?, error.domain == NSURLErrorDomain, error.code == NSURLErrorNotConnectedToInternet {
                                    self.noInternetConnectionAlert()
                                    return
                                }
                                print(NSString.init(data: data, encoding: String.Encoding.utf8.rawValue))
                            }
                        }
                    }
                }
    }).resume()
}
