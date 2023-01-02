# Voca+ -sample

Coding sample from **Voca+**, the *vocabulary-reference* **iOS app** that I created using **Swift**, **UIKit**, **Interface Builder**, **SQLite**, **Oxford Languages API**, **Xcode**. 

## FUNCTIONALITY 
This coding excerpt implements:
- *looking up* a word in The Oxford Dictionary, 
- *saving* it to a SQLite database, and
- *displaying* it's definition.

## USER INTERFACE
The segments implement a pared-down user interface, i.e:
- the interactivity of a look up button. 

The associated functions, triggered by the button, handle calling the API. The code reflects the nested structure of the Oxford Languages API and accesses the relevant endpoints, parses the returned JSON data and displays it into the view. 

I also implement error handling:
- In order to avoid calling the API too frequently, I check if the word inputed by the user doesn’t already exist in the SQLite database. 
- I also check for an internet connection in order to prevent the app crashing when no wifi or data roaming is enabled on the user’s device. 
- I also sanitise user input by default, making sure to remove any special characters or extraneous spaces.
