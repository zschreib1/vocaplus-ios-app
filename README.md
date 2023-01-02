# Voca+ -sample

Coding sample from **Voca+**, the *vocabulary-reference* **iOS app** that I created using **Swift**, **UIKit**, **Interface Builder**, **SQLite**, **Oxford Languages API**, **Xcode**. 

## FUNCTIONALITY 
This coding excerpt implements:
- *looking up* a word in The Oxford Dictionary, 
- *saving* it to a SQLite database, and
- *displaying* it's definition.

It also implement error handling:
- In order to avoid calling the API too frequently, I check if the word inputed by the user doesn’t already exist in the SQLite database. 
- I also check for an internet connection in order to prevent the app crashing when no wifi or data roaming is enabled on the user’s device. 
- I sanitise the user input by default, making sure to remove any special characters or extraneous spaces.

## USER INTERFACE
The segments implement the interactivity of a:
- look up button. 

## FUNCTIONS

- *@IBAction func lookUp(_ sender: UIButton)*  Handles the behavior of the look-up button and calling the API.
- *func triggerOrDismissAPICall (duplicate: Bool) -> Bool*. Triggers the API call if the word inputed by the user doesn't already exist in the database.
- *func sanitizedWordId() -> (String)*  Sanitizes the user input and returns the word_id that will be used to make the API call
- *func duplicateMatch() -> Bool*  Checks whether the entry is a duplicate or not. 
- *func APICall()*  Handles the API call. The function reflects the nested structure of the Oxford Languages API. It accesses the relevant API endpoints, parse the returned JSON data and displays it into the user interface. 
