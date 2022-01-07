//
//  MainView.swift
//  ASL for All
//
//  Created by Thatcher Clough on 8/8/21.
//

import SwiftUI
import SwiftfulLoadingIndicators
import SwiftSoup
import Shimmer
import Keys

let defaultAnimation: Animation = .spring(response: 0.35, dampingFraction: 0.8, blendDuration: 1)
let transitionDuration: Double = 0.35 / 2
let defaultTransition: AnyTransition = .scale.animation(Animation.spring(response: 0.35 / 2, dampingFraction: 1, blendDuration: 1))

struct MainView: View {
    @ObservedObject var mainViewModel: MainViewModel = MainViewModel()
    
    var body: some View {
        VStack {
            ZStack {
                if !mainViewModel.showTextfield {
                    Text("ASL for All")
                        .font(Font.custom("Config Rounded Semibold", size: 23))
                }
                
                HStack {
                    if mainViewModel.showLoading || mainViewModel.showVideo {
                        Button {
                            mainViewModel.reset()
                        } label: {
                            Image(systemName: "chevron.backward")
                        }
                        .buttonStyle(CircularButtonStyle(size: 20, height: 35))
                    }
                    
                    Spacer()
                    
                    if mainViewModel.showTextfield {
                        Button {
                            mainViewModel.showSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                        }
                        .buttonStyle(CircularButtonStyle(size: 20, height: 35))
                    } else if mainViewModel.showVideo {
                        ZStack {
                            if mainViewModel.exportLoading {
                                LoadingIndicator(animation: .circleRunner)
                                    .frame(width: 35, height: 35)
                                    .scaleEffect(0.75)
                                    .accentColor(.accentColor)
                                    .transition(defaultTransition)
                            }
                            
                            Button {
                                mainViewModel.export()
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(mainViewModel.exportLoading ? Color(UIColor.label).opacity(0.3) : nil)
                            }
                            .buttonStyle(CircularButtonStyle(size: 17, height: 35))
                            .disabled(mainViewModel.exportLoading)
                        }
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            
            Spacer()
            
            if mainViewModel.showTextfield {
                VStack {
                    Spacer()
                    
                    Text("ASL for All")
                        .font(Font.custom("Config Rounded Semibold", size: 43))
                        .padding(15)
                    
                    Text("An English to American Sign Language translator")
                        .font(.system(size: 20, weight: .regular))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    ZStack {
                        TextField("Word or sentence", text: $mainViewModel.textfieldText, onEditingChanged: { (editingChanged) in
                            if editingChanged {
                                mainViewModel.textFieldIsInFocus = true
                            } else {
                                mainViewModel.textFieldIsInFocus = false
                            }
                        })
                            .textFieldStyle(MainViewTextFieldStyle(font: .system(size: 17), height: 20, verticalPadding: 15, horizontalPadding: 40))
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                            
                            Spacer()
                            
                            if !mainViewModel.textfieldText.isEmpty && mainViewModel.textFieldIsInFocus {
                                Button {
                                    mainViewModel.textfieldText = ""
                                } label: {
                                    Image(systemName: "xmark")
                                }
                                .buttonStyle(CircularButtonStyle(size: 10, height: 20))
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                    .padding(25)
                    
                    Button {
                        if !mainViewModel.textfieldText.isEmpty {
                            DispatchQueue.main.asyncAfter(deadline: .now() + transitionDuration) {
                                mainViewModel.showTextfield = false
                                mainViewModel.loadingText = "Loading..."
                                mainViewModel.showLoading = true
                            }
                        }
                    } label: {
                        Text("Translate")
                    }
                    .buttonStyle(MainViewButtonStyle(font: .system(size: 20, weight: .medium), verticalPadding: 15, horizontalPadding: 15, cornerRadius: 1.5 * 15))
                    
                    Spacer()
                    Spacer()
                }
                .offset(y: -30)
                .transition(defaultTransition)
                .onDisappear() {
                    mainViewModel.handleInput(input: mainViewModel.textfieldText)
                }
            } else if mainViewModel.showVideo && mainViewModel.videoView != nil {
                mainViewModel.videoView
                    .onAppear() {
                        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                            mainViewModel.rootViewController = rootViewController
                            mainViewModel.rootViewController?.loadView()
                        }
                    }
            } else if !mainViewModel.wordWithMultipleMeanings.isEmpty && mainViewModel.wordMeaningsWithURLs.count > 0 && mainViewModel.words.contains(mainViewModel.wordWithMultipleMeanings) {
                VStack(alignment: .center) {
                    Text("Select meaning of \'\(mainViewModel.wordWithMultipleMeanings)\':")
                        .font(.system(size: 25, weight: .regular))
                    WrappedHStack(width: mainViewModel.screenWidth - 50, spacing: 5) {
                        let sortedKeys = Array(mainViewModel.wordMeaningsWithURLs.keys).sorted { (a, b) -> Bool in return a.count < b.count }
                        ForEach(sortedKeys, id: \.self) { selectedMeaning in
                            Button {
                                mainViewModel.wordMeaningSelected(selectedMeaning: selectedMeaning)
                            } label: {
                                Text(selectedMeaning)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(nil)
                            }
                            .buttonStyle(MainViewButtonStyle(font: .system(size: 20, weight: .regular), verticalPadding: 7, horizontalPadding: 13, cornerRadius: 15))
                        }
                    }
                }
                .transition(defaultTransition)
                .offset(y: -30)
            } else if mainViewModel.showLoading {
                Text(mainViewModel.loadingText)
                    .font(.system(size: 23, weight: .regular))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 30)
                    .transition(defaultTransition)
                    .shimmering(duration: 3.0)
                    .offset(y: -30)
            }
            
            Spacer()
        }
        .animation(defaultAnimation)
        .transition(defaultTransition)
        .onAppear() {
            mainViewModel.destroyCache()
            if UserDefaults.standard.object(forKey: "followASLWordOrder") == nil {
                mainViewModel.followASLWordOrder = true
            }
        }
        .alert(isPresented: $mainViewModel.showAlert) {
            Alert(
                title: Text(mainViewModel.alertTitle),
                message: Text(mainViewModel.alertMessage),
                dismissButton: .default(Text("Ok"))
            )
        }
        .sheet(isPresented: $mainViewModel.showSettings) {
            SettingsView(mainViewModel: mainViewModel, followASLWordOrder: mainViewModel.followASLWordOrder)
        }
    }
}

class MainViewModel: ObservableObject {
    let screenWidth: CGFloat = UIScreen.main.bounds.width
    
    var task: URLSessionDataTask? = nil
    
    var followASLWordOrder: Bool = UserDefaults.standard.bool(forKey: "followASLWordOrder") {
        didSet {
            UserDefaults.standard.set(followASLWordOrder, forKey: "followASLWordOrder")
        }
    }
    
    let webHelper: WebHelper = WebHelper()
    var words: [String] = []
    var remoteVideoURLs: [URL] = []
    var localVideoURLs: [URL] = []
    
    var videoView: VideoView?
    var exportedVideo: URL?
    var rootViewController: UIViewController?
    
    @Published var wordWithMultipleMeanings: String = ""
    @Published var wordMeaningsWithURLs: [String: URL] = [:]
    
    @Published var showSettings: Bool = false
    @Published var showTextfield: Bool = true
    @Published var textFieldIsInFocus: Bool = false
    @Published var textfieldText: String = ""
    @Published var showLoading: Bool = false
    @Published var loadingText: String = "Loading..."
    @Published var showVideo: Bool = false
    @Published var exportLoading: Bool = false
    
    @Published var showAlert: Bool = false
    var alertTitle: String = ""
    var alertMessage: String = ""
    
    func handleInput(input: String) {
        self.loadingText = "Loading..."
        DispatchQueue.global(qos: .userInitiated).async {
            var input: String = input
            
            // Remove whitespaces
            while input.prefix(1) == " " {
                input = String(input.suffix(input.count - 1))
            }
            while input.suffix(1) == " " {
                input = String(input.prefix(input.count - 1))
            }
            input = input.replacingOccurrences(of: "  ", with: " ")
            
            // Standardize apostrophes
            input = input.replacingOccurrences(of: "\u{0027}", with: "\'")
            input = input.replacingOccurrences(of: "\u{2018}", with: "\'")
            input = input.replacingOccurrences(of: "\u{2019}", with: "\'")
            
            // Remove contractions (splits and combines words)
            var words = input.components(separatedBy: " ")
            if let contractionsFile = Bundle.main.path(forResource: "contractions", ofType: "json") {
                do {
                    let contrationsFileURL = URL(fileURLWithPath: contractionsFile)
                    let contractionsData = try Data(contentsOf: contrationsFileURL)
                    if let contractionsJson = try JSONSerialization.jsonObject(with: contractionsData, options: .mutableContainers) as? [String: String] {
                        for index in 0..<words.count {
                            if let contractionReplacement = contractionsJson[words[index].lowercased()] {
                                words.remove(at: index)
                                words.insert(contractionReplacement, at: index)
                            }
                        }
                        input = words.joined(separator: " ")
                    }
                } catch {
                    self.handleError(errorMessage: "Could not parse contractions file.")
                    return
                }
            } else {
                self.handleError(errorMessage: "Could not access contractions file.")
                return
            }
            
            if input.isEmpty {
                self.handleError(errorMessage: "Enter a valid word or sentence")
            }
            
            // Convert to ASL grammar
            if self.followASLWordOrder && input.contains(" ") {
                DispatchQueue.main.async {
                    self.loadingText = "Converting to ASL grammar..."
                }
                
                let defaults = UserDefaults.standard
                if let storredTranslations = defaults.object(forKey: "storredTranslations") as? [String: String] {
                    if let translation = storredTranslations[input] {
                        self.words = translation.components(separatedBy: " ")
                        self.handleNextWord()
                        return
                    }
                } else {
                    defaults.setValue([:], forKey: "storredTranslations")
                }
                
                var components = URLComponents()
                components.scheme = "https"
                components.host = ASLForAllKeys().aPIBaseURL
                components.path = "/api/translate"
                components.queryItems = [URLQueryItem(name: "sentence", value: input)]
                let url = components.url!
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                self.task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                    if error != nil || data == nil {
                        if error != nil && error?.localizedDescription == "cancelled" {
                            return
                        }
                        self.handleNotice(noticeMessage: "Could not translate grammar (API did not respond).")
                        self.words = input.components(separatedBy: " ")
                        self.handleNextWord()
                        return
                    }
                    
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: String] {
                            if let translation = json["translation"] {
                                if var storredTranslations = defaults.object(forKey: "storredTranslations") as? [String: String] {
                                    storredTranslations[input] = translation
                                    defaults.setValue(storredTranslations, forKey: "storredTranslations")
                                }
                                
                                self.words = translation.components(separatedBy: " ")
                                self.handleNextWord()
                                return
                            } else if let error = json["error"] {
                                self.handleNotice(noticeMessage: "Could not translate grammar (API error: \(error).")
                                self.words = input.components(separatedBy: " ")
                                self.handleNextWord()
                                return
                            } else {
                                self.handleNotice(noticeMessage: "Could not translate grammar (API returned an error).")
                                self.words = input.components(separatedBy: " ")
                                self.handleNextWord()
                                return
                            }
                        }
                    } catch {
                        self.handleNotice(noticeMessage: "Could not translate grammar (An error occurred when parsing API data).")
                        self.words = input.components(separatedBy: " ")
                        self.handleNextWord()
                        return
                    }
                })
                self.task?.resume()
            } else {
                self.words = input.components(separatedBy: " ")
                self.handleNextWord()
                return
            }
        }
    }
    
    var dispatchItem: DispatchWorkItem? = nil
    var indexOfWordBeingHandled: Int = 0
    func handleNextWord() {
        dispatchItem = DispatchWorkItem {
            if self.dispatchItem != nil && !self.dispatchItem!.isCancelled {
                DispatchQueue.main.async {
                    self.loadingText = "Getting videos..."
                }
                
                if self.indexOfWordBeingHandled >= self.words.count { // Done getting video URLs
                    if self.remoteVideoURLs.isEmpty {
                        self.handleError(errorMessage: "No videos found. Make sure you are connected to the internet and try again.")
                    } else {
                        self.downloadVideos(urls: self.remoteVideoURLs, index: 0) { urls in
                            if urls != nil {
                                DispatchQueue.main.async {
                                    self.localVideoURLs = urls!
                                    self.videoView = VideoView(urls: self.localVideoURLs, words: self.words, wrappedHStackWidth: self.screenWidth - 50)
                                    self.showVideo = true
                                }
                            } else {
                                self.handleError(errorMessage: "Could not download videos.")
                            }
                        }
                    }
                } else {
                    let word = self.words[self.indexOfWordBeingHandled]
                    if let pageURL = self.webHelper.getPageURL(word: word) {
                        if let document = self.webHelper.getPageDocument(pageURL: pageURL) {
                            if let pageContainsSearchResults = self.webHelper.pageContainsSearchResults(pageDocument: document) {
                                if pageContainsSearchResults { // Word does not have a signle sign
                                    let searchOptions = self.webHelper.getPageSearchOptions(pageDocument: document)
                                    if searchOptions?.array() != nil { // Word has multiple meanings
                                        let searchOptionsArray = searchOptions!.array()
                                        if self.dispatchItem != nil && !self.dispatchItem!.isCancelled {
                                            self.handleWordHasMultipleMeanings(word: word, meanings: searchOptionsArray)
                                        }
                                    } else {
                                        if self.dispatchItem != nil && !self.dispatchItem!.isCancelled {
                                            self.handleWordHasNoSign(word: word) { url in
                                                if url != nil {
                                                    if self.dispatchItem != nil && !self.dispatchItem!.isCancelled {
                                                        self.remoteVideoURLs.append(url!)
                                                        self.indexOfWordBeingHandled += 1
                                                        self.handleNextWord()
                                                    }
                                                } else {
                                                    self.handleHandleNextWordError(errorMessage: "Could not get letter videos (API did not respond). Make sure you are connected to the internet and try again.")
                                                }
                                            }
                                        }
                                    }
                                } else { // Word has one sign
                                    self.webHelper.getVideoURL(pageURL: pageURL) { url in
                                        if url != nil {
                                            if self.dispatchItem != nil && !self.dispatchItem!.isCancelled {
                                                self.remoteVideoURLs.append(url!)
                                                self.indexOfWordBeingHandled += 1
                                                self.handleNextWord()
                                            }
                                        } else {
                                            self.handleHandleNextWordError(errorMessage: "Could not get video for \'" + word + "\'. Make sure you are connected to the internet and try again.")
                                        }
                                    }
                                }
                            } else {
                                self.handleHandleNextWordError(errorMessage: "Could not get video for \'" + word + "\' (No search results). Make sure you are connected to the internet and try again.")
                            }
                        } else {
                            self.handleHandleNextWordError(errorMessage: "Could not get video for \'" + word + "\' (No page document). Make sure you are connected to the internet and try again.")
                        }
                    } else {
                        self.handleHandleNextWordError(errorMessage: "Could not get video for \'" + word + "\' (No page URL). Make sure you are connected to the internet and try again.")
                    }
                }
            }
        }
        DispatchQueue.global().async(execute: dispatchItem!)
    }
    
    func handleWordHasNoSign(word: String, completion: @escaping (_ url: URL?) -> Void) {
        let group = DispatchGroup()
        
        let letters = word.map({String($0)})
        var letterVideoURLs: [URL?] = [URL?](repeating: nil, count: letters.count)
        
        for index in 0..<letters.count {
            group.enter()
            if Array(letters[index])[0].isLetter {
                if let pageURL = webHelper.getPageURL(letter: letters[index]) {
                    webHelper.getVideoURL(pageURL: pageURL) { [self] url in
                        if url != nil {
                            letterVideoURLs[index] = url!
                            group.leave()
                        } else {
                            self.handleHandleNextWordError(errorMessage: "Could not get video for \'" + letters[index] + "\'. Make sure you are connected to the internet and try again.")
                            return
                        }
                    }
                } else {
                    handleHandleNextWordError(errorMessage: "Could not get video for \'" + letters[index] + "\'. Make sure you are connected to the internet and try again.")
                    return
                }
            } else {
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            if self.dispatchItem != nil && !self.dispatchItem!.isCancelled {
                self.concatenateVideos(videoURLs: letterVideoURLs) { url in
                    return completion(url)
                }
            }
        }
    }
    
    func handleWordHasMultipleMeanings(word: String, meanings: [Element]) {
        var meaningsWithURLs: [String: URL] = [String: URL]()
        for index in 0..<meanings.count {
            let meaning = meanings[index]
            let (meaningText, meaningURL) = self.webHelper.getOptionAndURL(option: meaning)
            
            if meaningText != nil && meaningURL != nil {
                meaningsWithURLs[meaningText!] = meaningURL
            }
        }
        
        if meaningsWithURLs.isEmpty {
            if self.dispatchItem != nil && !self.dispatchItem!.isCancelled {
                self.handleWordHasNoSign(word: word) { url in
                    if url != nil {
                        if self.dispatchItem != nil && !self.dispatchItem!.isCancelled {
                            self.remoteVideoURLs.append(url!)
                            self.indexOfWordBeingHandled += 1
                            self.handleNextWord()
                        }
                    } else {
                        self.handleHandleNextWordError(errorMessage: "Could not get letter videos (API did not respond). Make sure you are connected to the internet and try again.")
                    }
                }
            }
        } else {
            if self.dispatchItem != nil && !self.dispatchItem!.isCancelled {
                DispatchQueue.main.async {
                    self.wordMeaningsWithURLs = meaningsWithURLs
                    DispatchQueue.main.asyncAfter(deadline: .now() + transitionDuration) {
                        self.wordWithMultipleMeanings = word
                    }
                }
            }
        }
    }
    
    func wordMeaningSelected(selectedMeaning: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionDuration) {
            let word = self.wordWithMultipleMeanings
            let pageURL = self.wordMeaningsWithURLs[selectedMeaning]
            self.wordWithMultipleMeanings = ""
            self.wordMeaningsWithURLs = [:]
            
            if pageURL != nil {
                self.webHelper.getVideoURL(pageURL: pageURL!) { url in
                    if url != nil {
                        self.remoteVideoURLs.append(url!)
                        self.indexOfWordBeingHandled += 1
                        self.handleNextWord()
                    } else {
                        self.handleError(errorMessage: "Could not get video for \'" + word + "\' (No page URL). Make sure you are connected to the internet and try again.")
                    }
                }
            } else {
                self.handleError(errorMessage: "Could not get video for \'" + word + "\' (No page URL). Make sure you are connected to the internet and try again.")
            }
        }
    }
    
    var numberOfRetries: Int = 0
    func handleHandleNextWordError(errorMessage: String) {
        if showTextfield {
            return
        }
        
        if numberOfRetries <= 3 {
            handleNextWord()
            numberOfRetries += 1
        } else {
            numberOfRetries = 0
            handleError(errorMessage: errorMessage)
            return
        }
    }
    
    func downloadVideos(urls: [URL], index: Int, completion: @escaping (_ urls: [URL]?) -> Void) {
        if index == urls.count {
            return completion(urls)
        } else {
            self.downloadVideo(url: urls[index], filename: "\(index).mp4") { url in
                if url != nil {
                    var urls = urls
                    urls[index] = url!
                    self.downloadVideos(urls: urls, index: index + 1) { urls in
                        return completion(urls)
                    }
                } else {
                    return completion(nil)
                }
            }
        }
    }
    
    func downloadVideo(url: URL, filename: String, completion: @escaping (_ url: URL?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let filename = filename.lowercased()
                let fileURL = documentsDir.appendingPathComponent(filename.lowercased())
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    do {
                        try FileManager.default.removeItem(at: fileURL)
                    } catch {
                        return completion(nil)
                    }
                }
                URLSession.shared.downloadTask(with: url) { (location, response, error) -> Void in
                    guard let location = location else {
                        return completion(nil)
                    }
                    let fileURL = documentsDir.appendingPathComponent(filename)
                    do {
                        try FileManager.default.moveItem(at: location, to: fileURL)
                        return completion(fileURL)
                    } catch {
                        return completion(location)
                    }
                }
                .resume()
            } else {
                return completion(nil)
            }
        }
    }
    
    func concatenateVideos(videoURLs: [URL?], completion: @escaping (_ url: URL?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var components = URLComponents()
            components.scheme = "https"
            components.host = ASLForAllKeys().aPIBaseURL
            components.path = "/api/concatenate"
            var queryItems: [URLQueryItem] = []
            for videoURL in videoURLs {
                if videoURL != nil {
                    queryItems.append(URLQueryItem(name: "videos", value: videoURL!.absoluteString))
                }
            }
            components.queryItems = queryItems
            let url = components.url!
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            self.task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                if error != nil || data == nil {
                    return completion(nil)
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: String] {
                        if let concatenatedVideoURLString = json["concatenated video"] {
                            if let concatenatedVideoURL = URL(string: concatenatedVideoURLString) {
                                return completion(concatenatedVideoURL)
                            } else {
                                return completion(nil)
                            }
                        } else {
                            return completion(nil)
                        }
                    }
                } catch {
                    return completion(nil)
                }
            })
            self.task?.resume()
        }
    }
    
    func export() {
        if self.exportedVideo != nil {
            self.presentShareSheet(item: self.exportedVideo!)
        } else {
            if self.remoteVideoURLs.count > 1 {
                DispatchQueue.main.async {
                    self.exportLoading = true
                }
                self.concatenateVideos(videoURLs: self.remoteVideoURLs) { url in
                    if url != nil {
                        self.downloadVideo(url: url!, filename: "\(self.words.joined(separator: "_")).mp4") { url in
                            if url != nil {
                                DispatchQueue.main.async {
                                    self.exportedVideo = url!
                                    self.exportLoading = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + transitionDuration) {
                                        self.presentShareSheet(item: self.exportedVideo!)
                                    }
                                }
                            } else {
                                if self.dispatchItem != nil && !self.dispatchItem!.isCancelled {
                                    DispatchQueue.main.async {
                                        self.handleNotice(noticeMessage: "Could not download video")
                                        self.exportLoading = false
                                        self.exportedVideo = nil
                                    }
                                }
                            }
                        }
                    } else {
                        if self.dispatchItem != nil && !self.dispatchItem!.isCancelled {
                            DispatchQueue.main.async {
                                self.handleNotice(noticeMessage: "Could not prepare videos")
                                self.exportLoading = false
                                self.exportedVideo = nil
                            }
                        }
                    }
                }
            } else if self.remoteVideoURLs.count == 1 {
                self.downloadVideo(url: self.remoteVideoURLs[0], filename: "\(self.words.joined(separator: "_")).mp4") { url in
                    if url != nil {
                        DispatchQueue.main.async {
                            self.exportedVideo = url!
                            self.exportLoading = false
                            self.presentShareSheet(item: self.exportedVideo!)
                        }
                    } else {
                        if self.dispatchItem != nil && !self.dispatchItem!.isCancelled {
                            DispatchQueue.main.async {
                                self.handleNotice(noticeMessage: "Could not download video")
                                self.exportLoading = false
                                self.exportedVideo = nil
                            }
                        }
                    }
                }
            }
        }
    }
    
    func presentShareSheet(item: URL) {
        let shareSheet = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        self.rootViewController?.present(shareSheet, animated: true, completion: nil)
    }
    
    func handleError(errorMessage: String) {
        DispatchQueue.main.async {
            self.reset()
            self.alertTitle = "Error"
            self.alertMessage = errorMessage
            self.showAlert = true
        }
    }
    
    func handleNotice(noticeMessage: String) {
        DispatchQueue.main.async {
            self.alertTitle = "Notice"
            self.alertMessage = noticeMessage
            self.showAlert = true
        }
    }
    
    func reset() {
        task?.cancel()
        words = []
        remoteVideoURLs = []
        localVideoURLs = []
        videoView = nil
        exportedVideo = nil
        wordWithMultipleMeanings = ""
        wordMeaningsWithURLs = [:]
        showSettings = false
        showTextfield = true
        textFieldIsInFocus = false
        textfieldText = ""
        showLoading = false
        loadingText = "Loading..."
        showVideo = false
        exportLoading = false
        showAlert = false
        dispatchItem?.cancel()
        indexOfWordBeingHandled = 0
        numberOfRetries = 0
    }
    
    func destroyCache() {
        let fileManager = FileManager.default
        let documentsUrl =  fileManager.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first! as NSURL
        let documentsPath = documentsUrl.path
        let bundleIdentifier = Bundle.main.bundleIdentifier! as String
        do {
            if let documentPath = documentsPath
            {
                let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentPath)/\(bundleIdentifier)")
                for fileName in fileNames {
                    let filePathName = "\(documentPath)/\(bundleIdentifier)/\(fileName)"
                    try fileManager.removeItem(atPath: filePathName)
                }
            }
        } catch {
            print("Could not destroy cache: \(error)")
        }
    }
}

struct MainViewTextFieldStyle: TextFieldStyle {
    let font: Font
    let height: CGFloat
    let verticalPadding: CGFloat
    let horizontalPadding: CGFloat
    @Environment(\.colorScheme) var colorScheme
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(font)
            .frame(height: height)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .background(colorScheme == .dark ? Color.white.opacity(0.14) : Color.black.opacity(0.07))
            .cornerRadius(1.5 * verticalPadding)
    }
}

struct MainViewButtonStyle: ButtonStyle {
    let font: Font
    let verticalPadding: CGFloat
    let horizontalPadding: CGFloat
    let cornerRadius: CGFloat
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(font)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
            .lineLimit(nil)
            .shadow(color: .accentColor.opacity(0.4), radius: 10, y: 0)
    }
}

struct CircularButtonStyle: ButtonStyle {
    let size: CGFloat
    let height: CGFloat
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.system(size: size))
            .frame(width: height, height: height)
            .background(colorScheme == .dark ? Color.white.opacity(0.2) : Color(UIColor.label).opacity(0.09))
            .foregroundColor(Color(UIColor.label))
            .cornerRadius(height / 2)
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
    }
}
