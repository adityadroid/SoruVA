

import UIKit
import SwiftSpinner
import ConversationV1
import JSQMessagesViewController
import BMSCore

//FIND WEATHER
//MAKE A PHONE CALL
//GET IMAGE FROM UNSPLASH
//OPEN MAPS
//GET INTRO FROM WIKIPEDIA
//GET RESPONSE FROM IBM WATSON
//GET ANSWERS FROM WOLFRAM ALPHA
//GET LYRICS OF A SONG




class ViewController: JSQMessagesViewController{
    
    // Configure chat settings for JSQMessages
    var incomingChatBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1.0))
    var outgoingChatBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    fileprivate let kCollectionViewCellHeight: CGFloat = 12.5
    
    // Configure Watson Conversation items
    var conversationMessages = [JSQMessage]()
    var conversation : Conversation!
    var context: Context?
    var workspaceID: String!
    var currentIntent : String = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setupTextBubbles()
        self.applyTheme()
        // Remove attachment icon from toolbar
        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.inputToolbar.contentView.rightBarButtonItem.setImage( UIImage(named: "send-button(1).png"), for : .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
      
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
      //      navigationController?.navigationBar.barTintColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
      //  navigationController?.navigationBar.tintColor = UIColor.white
     //   rgba(231, 76, 60,1.0)
    }
    
    
    func reloadMessagesView() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.applyTheme()
        SwiftSpinner.show("Connecting to Soru", animated: true)
        
        // Create a configuration path for the BMSCredentials.plist file to read in Watson credentials
        let configurationPath = Bundle.main.path(forResource: "BMSCredentials", ofType: "plist")
        let configuration = NSDictionary(contentsOfFile: configurationPath!)
        // Set the Watson credentials for Conversation service from the BMSCredentials.plist
        let conversationPassword = configuration?["conversationPassword"] as! String
        let conversationUsername = configuration?["conversationUsername"] as! String
        let conversationWorkspaceID = "79feeb83-33d1-498c-8ef8-cb71bb8ef4f6"
        self.workspaceID = conversationWorkspaceID
        // Create date format for Conversation service version
        let version = "2016-12-15"
        // Initialize conversation object
        conversation = Conversation(username: conversationUsername, password: conversationPassword, version: version)
        // Initial conversation message from Watson
        conversation.message(withWorkspace: self.workspaceID, failure: failConversationWithError){
            response in
            for watsonMessage in response.output.text{
                // Create message object with Watson response
                let message = JSQMessage(senderId: "Watson", displayName: "Watson", text: watsonMessage)
                // Add message to conversation message array
                self.conversationMessages.append(message!)
                // Set current context
                self.context = response.context
                DispatchQueue.main.async {
                    self.finishSendingMessage()
                    SwiftSpinner.hide()
                }
            }
        }
    }
    
    
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            
            self.keyboardController.textView?.resignFirstResponder()
            self.didPressSend(nil, withMessageText:self.keyboardController.textView?.text , senderId:self.senderId , senderDisplayName: self.senderDisplayName, date: NSDate() as Date!)
            return false
        }
        
        return true
    }
   
    func didBecomeActive(_ notification: Notification) {
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Function handling errors with Tone Analyzer
    func failConversationWithError(_ error: Error) {
        // Print the error to the console
        print(error)
        SwiftSpinner.hide()
        // Present an alert to the user describing what the problem may be
        DispatchQueue.main.async {
            self.showAlert("Conversation Failed", alertMessage: "The Conversation service failed to reply. This could be due to invalid creditials, internet connection or other errors. Please verify your credentials in the WatsonCredentials.plist and rebuild the application. See the README for further assistance.")
        }
    }
    
    // Function to show an alert with an alertTitle String and alertMessage String
    func showAlert(_ alertTitle: String, alertMessage: String){
        // If an alert is not currently being displayed
        if(self.presentedViewController == nil){
            // Set alert properties
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
            // Add an action to the alert
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            // Show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Setup text bubbles for conversation
    func setupTextBubbles() {
        // Create sender Id and display name for user
        self.senderId = "TestUser"
        self.senderDisplayName = "TestUser"
        // Set avatars for user and Watson
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 28, height:32 )
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 37, height:37 )
        automaticallyScrollsToMostRecentMessage = true
        
    }
    // Set how many items are in the collection view
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.conversationMessages.count
    }
    
    // Set message data for each item in the collection view
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return self.conversationMessages[indexPath.row]
        
    }
    
    // Set whih bubble image is used for each message
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        return conversationMessages[indexPath.item].senderId == self.senderId ? outgoingChatBubble : incomingChatBubble
        
    }
    
    // Set which avatar image is used for each chat bubble
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        let message = conversationMessages[(indexPath as NSIndexPath).item]
        var avatar: JSQMessagesAvatarImage
        if (message.senderId == self.senderId){
            avatar  = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named:"boy"), diameter: 37)
        }
        else{
            avatar  = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named:"watson_avatar"), diameter: 32)
        }
        return avatar
    }
    
    // Create and display timestamp for every third message in the collection view
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        if ((indexPath as NSIndexPath).item % 3 == 0) {
            let message = conversationMessages[(indexPath as NSIndexPath).item]
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        return nil
    }
    
    // Set the height for the label that holds the timestamp
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return kCollectionViewCellHeight
    }
    
    // Create the cell for each item in collection view
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
            as! JSQMessagesCollectionViewCell
        let message = self.conversationMessages[(indexPath as NSIndexPath).item]
        // Set the UI color of each cell based on who the sender is
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.black
        } else {
            if let tv = cell.textView{
                tv.textColor = UIColor.white
                
            }
        }
        return cell
    }
    
    // Handle actions when user presses send button
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        // Create message based on user text
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        // Add message to conversation messages array of JSQMessages
        self.conversationMessages.append(message!)
        DispatchQueue.main.async {
            self.finishSendingMessage()
        }
        
        // Get response from Watson based on user text
        if(!text.contains("-")){
        let messageRequest = MessageRequest(text: text, context: self.context)
        conversation.message(withWorkspace: self.workspaceID, request: messageRequest, failure: failConversationWithError) { response in
            // Set current context
            self.context = response.context
            // Handle Watson response
            print(response)
            
            var confidence = 0.75
            var currentIntent = ""
            for item in response.intents{
                
                if(item.confidence > confidence){
                    currentIntent = item.intent
                    confidence = item.confidence
                }
                
            }
            for watsonMessage in response.output.text{
                if(!watsonMessage.isEmpty){
                    
                    
                    if(currentIntent != ""){  // Create message based on Watson response
                    self.displayMessage(watsonMessage)
                    }
                }
            }

            switch currentIntent{
                
                case "city_name":
                    self.findWeather((response.input?.text)!)
                    
                break
            case "phone":
                print("Calling")
                if (response.entities.count >= 1){
                    for entity in response.entities{
                        if(entity.entity == "sys-number"){
                        self.makePhoneCall(entity.value)
                        break
                        }
                    }
                }else{
                    self.displayMessage("Sorry I didn't get that!")
                }

                break
            case "locate_amenity":
                
                if (response.entities.count >= 1){
                    if(response.entities[0].value != "restaurant"){
                        self.openNavigation(response.entities[0].value)
                    }
                }else{
                    self.getWolframAlphaResponse((response.input?.text)!)
                  //  self.displayMessage("Sorry I didn't get that!")
                }

                
                break
                
            case "greetings":
                
                if (response.entities.count >= 1){
                    if(response.entities[0].value != "restaurant"){
                        self.openNavigation(response.entities[0].value)
                    }
                }

                break
                
                
            case "image_search":
                
                self.getImage((response.input?.text)!)
                break
                
                
            case "wiki_search":
                if (response.entities.count >= 1){
                    for entity in response.entities{
                        if(entity.entity == "sys-number"){
                            self.getWolframAlphaResponse((response.input?.text)!)

                        }else{
                        self.getWikiIntro(entity.value, (response.input?.text)!)
                        }
                        
                    }
                }else{
                    self.getWolframAlphaResponse((response.input?.text)!)

                   // self.displayMessage("Sorry I didn't get that!")
                }

                break
                
                
                
            case "out_of_scope":
                
                self.getWolframAlphaResponse((response.input?.text)!)
                break
                
            case "information_request":
                self.getWolframAlphaResponse((response.input?.text)!)
                
                break
                
                
            case "song_name":
             //   for watsonMessage in response.output.text{
                    
                    //if(watsonMessage == "Sure, Respond with \"Song Name - Artist Name\""){
                        let items = response.input?.text.components(separatedBy: "-")
                        print(items)
                        self.getLyrics(items![0], items![1])
                        
                   // }
               // }
               
                
                break
            
            case "weather","lyrics_search":
                break
            
                default:
                    self.getWolframAlphaResponse((response.input?.text)!)

                break
                
            }
            
        }
    
        }else{
            
            let items = text.components(separatedBy: "-")
            print(items)
            self.getLyrics(items[0], items[1])
            
        }
    }
    
    
    
    //FIND WEATHER
    
//    func findWeatherr(_city : String){
//        
//        
//        
//        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=London,uk&appid=0178dc4c3506656331c9d6e475ee9686")
//    
//    
//    }
    
    func findWeather(_ city : String){
        
        var message : String!
        
        
        
            if  let url = URL(string: "http://www.weather-forecast.com/locations/"+city+"/forecasts/latest") {
            
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request){
                data, response, error in
                if error != nil{
                    print(error ?? "nil")
                }else{
                    let unwrappedData = NSMutableString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    //                print(unwrappedData!)
                    let stringIdentifier = "3 Day Weather Forecast Summary:</b><span class=\"read-more-small\"><span class=\"read-more-content\"> <span class=\"phrase\">"
                    if let contentArray = unwrappedData?.components(separatedBy: stringIdentifier){
                        //  print(contentArray[1])
                        if(contentArray.count>1){
                            
                            let finalArray = contentArray[1].components(separatedBy: "</span></span></span></p>")
                            if(finalArray.count>0){
                                message = finalArray[0].replacingOccurrences(of: "&deg;", with: "°")
                                print(finalArray[0])
                            }
                        }
                        
                    }
                }
                
                if(message==""){
                    message = "Something went wrong!"
                }
                
                DispatchQueue.main.sync(execute: {
                    
                    
                    /// show weather

                   self.displayMessage(message)
                
                })
                
            }
            
            task.resume()
            
        }
        

    }
    
    
    
    
    
    //MAKE A PHONE CALL
    
    func makePhoneCall(_ number : String){
        let url  = URL(string:  "tel://"+number)
        if(UIApplication.shared.canOpenURL(url!)){
            print("Can Open")
      //  UIApplication.shared.open( URL(string: number)! , options: nil, completionHandler: nil)
        UIApplication.shared.openURL(url!)
        }
    }

    
    
    
    //DISPLAY A MESSAGE FROM SORU
    func displayMessage(_ msg : String){
        
        
        let JSQmessage = JSQMessage(senderId: "Watson", displayName: "Watson", text: msg)
        // Add message to conversation message array
        self.conversationMessages.append(JSQmessage!)
        DispatchQueue.main.async {
            self.finishSendingMessage()
        }
        
    }
    
    
    //GET IMAGE FROM UNSPLASH
    
    
    func getImage(_ query : String){
        let comp = query.components(separatedBy: " ")
        let defaultWords = 1
//        for i in (0..<comp.count).reversed(){
//            
//            if(comp[i]=="a"){
//                defaultWords = comp.count-i
//                break
//            }
//            
//        }
        var trimmedQuery = ""
        for i in (comp.count-defaultWords..<comp.count){
            
            trimmedQuery = trimmedQuery + comp[i]
            if(i != comp.count-1){
            trimmedQuery = trimmedQuery + "+"
            }
        }
            print(trimmedQuery)
        
        print("looking for image...")
        let url = URL(string: "https://api.unsplash.com/search/photos/?client_id=b0204a5caa5a8224f7a0946b7249f8c7b3859b9f7a8c7ca6c173cfd7cce988a9&query="+trimmedQuery)
        let task = URLSession.shared.dataTask(with: url!) {
            (data, response, error) in
                
                if(error != nil){
                    
                    print(error ?? "nil")
                }else{
                    
                  if let data = data {
                    
                    print(data)
                    do{
                        let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)  as! [String:Any]
                        if let results = jsonResult["results"] as? [[String : AnyObject]]{
                           // print("results")
                            if(results.count>0){
                             let result1 = results[0]
                         //   print(result1)
                            if let urls = result1["urls"] as? [String : AnyObject]{
                          //      print("urls")
                             //   print(urls)
                            //
                                
                                if let regular = urls["regular"] as? String{
                                    
                                    print(regular)
                                    self.downloadImage(url: URL(string: regular)!)
                                    //do something with the image
                                   // UIImage(data: )

                                }
                                
                            }
                            
                            }else{
                                
                                print("No Results")
                                
                            }}
                        
                    }catch{
                            print("JSONconversion failed")
                    }
                    }
                }
                
                
            
        }
        task.resume()
      
    }
    
    
    //OPEN MAPS
    
    func openNavigation(_ loc : String){
        let loc2 = loc.replacingOccurrences(of: " ", with: "+")
        let url  = URL(string:  "http://maps.apple.com/?q="+loc2)
        if(UIApplication.shared.canOpenURL(url!)){
            print("Can Open")
            //  UIApplication.shared.open( URL(string: number)! , options: nil, completionHandler: nil)
            UIApplication.shared.openURL(url!)
        }
    }
    
    
    
    
    //GET DATA FROM A URL
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    
    
    
    //DOWNLOAD IMAGE FROM A GIVEN URL
    
    
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
              
                //display the image
                let image  = UIImage(data: data)
                
                
                let mediaItem = JSQPhotoMediaItem(image: image)
                let JSQmessage = JSQMessage(senderId: "Watson", displayName: "Watson", media: mediaItem)
                //let JSQmessage = JSQMessage(senderId: "Watson", displayName: "Watson", text: msg)
                // Add message to conversation message array
                self.conversationMessages.append(JSQmessage!)
                self.finishSendingMessage()
                
            }
        }
    }
    
    
    //GET INTRO FROM WIKIPEDIA
    
    
    func getWikiIntro(_ query : String, _ completeQuery : String)
    {
        
        print("Getting data form wikipedia...")
        let modifQuery = query.replacingOccurrences(of: " ", with: "+")
        let url = URL(string: "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&titles="+modifQuery+"&indexpageids=true")
        
        let task = URLSession.shared.dataTask(with:url!){
        (data, response, error) in
            
            if( error != nil ){
                print(error!)
            }else{
                
                if let data = data{
                    do{
                    let jsonObject =  try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: Any]
                    
                        if let query = jsonObject["query"] as? [String: Any]{
                            print(query)
                            let pageids = query["pageids"] as! [String]
                            let pageID = pageids[0]
                            let pages = query["pages"] as! [String: AnyObject]
                            let content = pages[pageID] as! [ String : AnyObject]
                            if  let extract = content["extract"] as? String{
                                
                                print(extract)
                                if(extract == "" || extract == " "){
                                    self.getWolframAlphaResponse(completeQuery)
                                }else{
                                self.displayMessage(extract)
                                }
                            }else{
                                
                                self.displayMessage("No Results found!")
                            }
                            
                        }
                        
                    
                    }catch{
                        
                        print("JSON Serialization Failed!")
                    }
                    
                }
            }
            
            
        }
        task.resume()
        
    }
    
    
    
    
    //GET RESPONSE FROM WOLFRAM ALPHA
    
    func getWolframAlphaResponse(_ query : String){
        print("Getting data from wolfram alpha...")
        let escapedString = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let url = URL(string: "https://api.wolframalpha.com/v1/result?i="+escapedString!+"&appid=G82EPV-WYXHWHVQRY")
        let task = URLSession.shared.dataTask(with:url!){
            (data, response, error) in
            
            if(error != nil){
                
                print("Error")
            }else{
                
                
                if let data = data{
                    
                    
                    let unwrappedData = NSMutableString(data: data, encoding: String.Encoding.utf8.rawValue)
                    print(unwrappedData)
                    if(unwrappedData != "Wolfram|Alpha did not understand your input"){
                        self.displayMessage(unwrappedData! as String)
                        
                    }else{
                        self.displayMessage("Sorry I didn't get that!")
   
                    }
                    
                }
            }
            
            
            
        }
        task.resume()
    }
    
    
    
//    GET LYRICS OF A SONG
    
    func getLyrics( _ song : String, _ artist: String){
        
        
//        let escapedString = "http://api.chartlyrics.com/apiv1.asmx/SearchLyricDirect?artist="+artist.lowercased().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!+"&song=" + song.lowercased().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let escapedString = "http://www.azlyrics.com/lyrics/"+artist.lowercased().replacingOccurrences(of: " ", with: "")+"/"+song.lowercased().replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "'", with: "")+".html"
      print(escapedString)
        let url = URL(string: escapedString)
        
        let task = URLSession.shared.dataTask(with: url!){
             (data, response, error) in
            
            if(error != nil){
                
                print(error!)
            }else{
                
                if let data = data {
                    
                    
                    let unwrappedData = NSMutableString(data: data, encoding: String.Encoding.utf8.rawValue)
                    //print(unwrappedData!)
                    
                    //let startIdentifier = "<Lyric>"
                   // let endIdentifier = "</Lyric>"
                    let startIdentifier = "<!-- Usage of azlyrics.com content by any third-party lyrics provider is prohibited by our licensing agreement. Sorry about that. -->"
                    let endIdentifier = "</div>"
                    
                    let items = unwrappedData?.components(separatedBy: startIdentifier)
                    if((items?.count)!>1){
                        
                        let items2 = items?[1].components(separatedBy: endIdentifier)
                        if let lyrics = items2?[0]{
                            
                            print(lyrics)
                            var modifLyrics = lyrics.replacingOccurrences(of: "<br>", with: "")
                            modifLyrics = modifLyrics.replacingOccurrences(of: "<br><br>", with: "\n")
                            modifLyrics = modifLyrics.replacingOccurrences(of: "</i>", with: "")
                            modifLyrics = modifLyrics.replacingOccurrences(of: "<i>", with: "")
                            modifLyrics = modifLyrics.replacingOccurrences(of: "&amp;", with: "&")
                            
                            self.displayMessage(modifLyrics)
                        }else{
                            
                            self.displayMessage("Looks like I don't have lyrics for that song yet! Make sure the artist and the song are spelt correctly!")
                        }
                        
                        
                    }else{
                        self.displayMessage("Looks like I don't have lyrics for that song yet! Make sure the artist and the song are spelt correctly!")
                    }
                    
                }
                
            }
            
            
        }
        task.resume()
        
        
    }
    
    func applyTheme(){
        
        if(UserDefaults.standard.string(forKey: "primary") != nil &&
           UserDefaults.standard.string(forKey: "accent") != nil &&
            UserDefaults.standard.string(forKey: "user") != nil &&
            UserDefaults.standard.string(forKey: "watson") != nil
            ){
            print("applying theme")
            let primary = UserDefaults.standard.string(forKey: "primary")
            let accent = UserDefaults.standard.string(forKey: "accent")
            let user = UserDefaults.standard.string(forKey: "user")
            let watson = UserDefaults.standard.string(forKey: "watson")
            print("Primary theme",primary)
            print("Accent",accent)
            print("User",user)
            print("Watson",watson)
            
            self.inputToolbar.contentView.rightBarButtonItem.tintColor = getColor(color: accent!,itemType: "accent")
            navigationController?.navigationBar.barTintColor = getColor(color: primary!,itemType: "primary")
            if(primary != "white"){
            navigationController?.navigationBar.tintColor = UIColor.white
            }else{
                navigationController?.navigationBar.tintColor = UIColor.black
            }
            incomingChatBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: getColor(color: watson!,itemType: "watson"))
            outgoingChatBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: getColor(color: user!,itemType: "user"))
            
        }else{
            print("No theme found")
    
            UserDefaults.standard.set("red", forKey: "primary")
            UserDefaults.standard.set("red", forKey: "accent")
            UserDefaults.standard.set("red", forKey: "user")
            UserDefaults.standard.set("red", forKey: "watson")

            
        }
    }
    
    
   
    
}


func getColor(color : String, itemType: String)->UIColor{
    
    
    switch(itemType){
    case "primary" :
        switch(color){
            
        case "red" :
            return UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        case "blue" :
            return UIColor(red: 41.0/255.0, green: 128.0/255.0, blue: 185.0/255.0, alpha: 1.0)
        case "green" :
            return UIColor(red: 39.0/255.0, green: 174.0/255.0, blue: 96.0/255.0, alpha: 1.0)
        case "white" :
            return UIColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        case "black" :
            return UIColor(red: 52.0/255.0, green: 73.0/255.0, blue: 94.0/255.0, alpha: 1.0)
        default:
            break
            
        }
        break
    case "accent" :
        
        switch(color){
            
        case "red" :
            return UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        case "blue" :
            return UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 1.0)
        case "green" :
            return UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0)
        case "white" :
            return UIColor(red: 185.0/255.0, green: 195.0/255.0, blue: 199.0/255.0, alpha: 1.0)
        case "black" :
            return UIColor(red: 52.0/255.0, green: 73.0/255.0, blue: 94.0/255.0, alpha: 1.0)
        default:
            break
            
        }
        break
    case "user" :
        switch(color){
            
        case "red" :
            return UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        case "blue" :
            return UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 1.0)
        case "green" :
            return UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0)
        case "white" :
            return UIColor(red: 185.0/255.0, green: 195.0/255.0, blue: 199.0/255.0, alpha: 1.0)
        case "black" :
            return UIColor(red: 52.0/255.0, green: 73.0/255.0, blue: 94.0/255.0, alpha: 1.0)
        default:
            break
            
        }
        break
    case "watson" :
        switch(color){
            
        case "red" :
            return UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        case "blue" :
            return UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 1.0)
        case "green" :
            return UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0)
        case "white" :
            return UIColor(red: 185.0/255.0, green: 195.0/255.0, blue: 199.0/255.0, alpha: 1.0)
        case "black" :
            return UIColor(red: 52.0/255.0, green: 73.0/255.0, blue: 94.0/255.0, alpha: 1.0)
        default:
            break
            
        }
        break
        
    default :
        break
        
        
    }
    
    return UIColor.white
    
}
