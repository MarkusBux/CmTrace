//
//  String+RegEx.swift
//  CmTrace
//
//  Created by Alexis Gallagher
//  Reference: https://gist.github.com/algal/45e2efaf0c7ef1cd7372dc4caa847542
//

import Foundation

extension String {
    /**
     Returns a `[[Substring]]` of all matches of a `NSRegularExpression` against a `String`.
     
     - parameter regularExpression: the regular expression
     - parameter string: the String to match against
     - returns: a `[[Substring]]`, where every element represents a distinct match of the entire regular expression against `string`.
     
     In the return value, every element represents a distinct match of the entire regular expression against the `string`. Every element is itself an `Array<Substring>`, where each `Substring` is a substring for an individual capture group within that match. The first capture group (i.e., the 0th) is the entire regular expression itself.
     
     So for example, a match on the regular expression "a(.)z" produces two capture groups, the expression as a whole and the middle character. It expression would match three times against  the string "aaz abz acz". This would be expressed as the array [["aaz","a"], ["abz","b"], ["acz","c"]]
     
     */
    func captureGroupInMatches(of regularExpression:NSRegularExpression) -> [[Substring]]
    {
        let ms = regularExpression.matches(in: self, options: [],
                                           range: NSRange(self.startIndex..<self.endIndex,
                                                          in:self))
        return ms.map({
            (tcr:NSTextCheckingResult) -> [Substring] in
            let numberOfGroups = tcr.numberOfRanges
            let groupRanges = (0..<numberOfGroups).map({tcr.range(at: $0)})
            let groupSubstrings = groupRanges.map({ self[Range($0, in: self)!] })
            return groupSubstrings
        })
    }
    
    /// Returns the names of capture groups in the regular expression.
    private func namedCaptureGroups(inRegularExpression regularExpression:NSRegularExpression) -> [String]
    {
        let regexString = regularExpression.pattern
        let nameRegex = try! NSRegularExpression(pattern: "\\(\\?\\<(\\w+)\\>", options: [])
        let nameMatches = nameRegex.matches(in: regexString, options: [],
                                            range: NSRange(regexString.startIndex..<regexString.endIndex,
                                                           in:regexString))
        let names = nameMatches.map { (textCheckingResult) -> String in
            return (regexString as NSString).substring(with: textCheckingResult.range(at: 1))
        }
        return names
    }
    
    /**
     Returns a `[[String:Substring?]]` of all matches of a `NSRegularExpression` against a `String`.
     
     - parameter regularExpression: the regular expression
     - parameter string: the String to match against
     - returns: an `[[String:Substring?]]`, where every element represents a distinct match of the entire regular expression against `s`.
     
     In the return value, every element represents a distinct match of the entire regular expression against the string. Every element is itself a `Dictionary<String,Substring?>`, mapping the name of the capture groups to the Substring which matched that capture group.
     
     So for example, a match on the regular expression "a(?<middleChar.)z" includes one capture group named "middleChar". It would match three times against against the string "aaz abz acz". This would be expressed as the array [["middleChar":"a"], ["middleChar":"b"], ["middleChar":"c"]]
     
     */
    func namedCaptureGroupsInMatches(of regularExpression:NSRegularExpression) -> [[String:Substring?]]
    {
        let names = namedCaptureGroups(inRegularExpression: regularExpression)
        
        let ms = regularExpression.matches(in: self, options: [],
                                           range:NSRange(self.startIndex..<self.endIndex,
                                                         in:self))
        return ms.map({
            (tcr:NSTextCheckingResult) -> [String:Substring?] in
            let keyvalues = names.map({ (name:String) -> (String,Substring?) in
                let captureGroupRange = tcr.range(withName: name)
                if captureGroupRange.location == NSNotFound {
                    return (name,nil)
                }
                else {
                    return (name,self[Range(captureGroupRange, in: self)!])
                }
            })
            
            return Dictionary(uniqueKeysWithValues: keyvalues)
        })
    }
}
