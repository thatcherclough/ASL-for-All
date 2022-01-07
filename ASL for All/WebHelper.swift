//
//  WebHelper.swift
//  ASL for All
//
//  Created by Thatcher Clough on 8/10/21.
//

import SwiftSoup

class WebHelper: NSObject {
    private let baseURL = "https://www.signingsavvy.com/"
    private let baseCSS = "html body#page_signs.bg div#frame div#main.index div#main.sub div#main_content div#main_content_inner div#main_content_left div.content_module"
    private let letterURLs = ["sign/A/5820/1", "search/b", "search/c", "search/d", "search/e", "search/f", "sign/G/5826/1", "search/h", "sign/I/5828/1", "search/j", "search/k", "sign/L/5831/1", "sign/M/5832/1", "search/n", "search/o", "search/p", "search/q", "search/r", "search/s", "sign/T/5839/1", "search/u", "search/v", "search/w", "sign/X/5843/1", "search/y", "search/z"]
    
    func getPageURL(letter: String) -> URL? {
        let ascii = letter.uppercased().asciiValues[0]
        if ascii - 65 >= 0 && ascii - 65 < letterURLs.count {
            return URL(string: "\(baseURL)\(letterURLs[Int(ascii) - 65])")
        } else {
            return nil
        }
    }
    
    func getPageURL(word: String) -> URL? {
        return URL(string: "\(baseURL)search/\(word)")
    }
    
    func getPageDocument(pageURL: URL) -> Document? {
        do {
            let html = try String(contentsOf: pageURL, encoding: .utf8)
            let document = try SwiftSoup.parse(html)
            return document
        } catch {
            return nil
        }
    }
    
    func pageContainsSearchResults(pageDocument: Document) -> Bool? {
        do {
            if let searchResults = try pageDocument.select("\(baseCSS) h2").first() {
                let containsSearchResults = try searchResults.text().contains("Search Results")
                return containsSearchResults
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    func getPageSearchResults(pageURL: URL) -> Element? {
        do {
            let html = try String(contentsOf: pageURL, encoding: .utf8)
            let document = try SwiftSoup.parse(html)
            if let results = try document.select("\(baseCSS) h2").first() {
                return results
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    func getPageSearchOptions(pageDocument: Document) -> Elements? {
        do {
            let searchOptions = try pageDocument.select("\(baseCSS) div.search_results ul").first()?.children()
            return searchOptions
        } catch {
            return nil
        }
    }
    
    func getOptionAndURL(option: Elements.Element) -> (String?, URL?) {
        do {
            var optionText = try option.text().lowercased()
            if optionText.contains("&quot") && optionText.contains("\""){
                optionText = optionText.slice(from: "&quot", to: "\"")!
            }
            
            var optionURLString: String = "\(baseURL)\(try option.child(0).attr("href"))"
            if optionURLString.contains(" ") {
                optionURLString = optionURLString.replacingOccurrences(of: " ", with: "%20")
            }
            
            if let optionURL = URL(string: optionURLString) {
                return (optionText, optionURL)
            } else {
                return (nil, nil)
            }
        } catch {
            return (nil, nil)
        }
    }
    
    func getVideoURL(pageURL: URL, completion: @escaping (_ url: URL?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let html = try String(contentsOf: pageURL, encoding: .utf8)
                let document = try SwiftSoup.parse(html)
                if let video = try document.select("\(self.baseCSS) div.sign_module div.signing_body div.videocontent link").first() {
                    let url = try video.attr("href")
                    return completion(URL(string: "\(self.baseURL)\(url)"))
                } else {
                    return completion(nil)
                }
            } catch {
                return completion(nil)
            }
        }
    }
}

extension StringProtocol {
    var asciiValues: [UInt8] { compactMap(\.asciiValue) }
}

extension String {
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}
