import Foundation

class FuzzyMatcher {
    /// Returns a score for how well the query matches the target.
    /// Higher scores = better matches. Returns nil if no match.
    static func score(query: String, target: String) -> Int? {
        if query.isEmpty { return 100 }
        
        let queryChars = Array(query.lowercased())
        let targetLower = target.lowercased()
        let targetChars = Array(targetLower)
        
        var queryIndex = 0
        var targetIndex = 0
        var score = 0
        var consecutiveBonus = 0
        var lastMatchIndex = -2
        
        while queryIndex < queryChars.count && targetIndex < targetChars.count {
            if queryChars[queryIndex] == targetChars[targetIndex] {
                // Base score for match
                score += 10
                
                // Bonus for consecutive matches
                if targetIndex == lastMatchIndex + 1 {
                    consecutiveBonus += 5
                    score += consecutiveBonus
                } else {
                    consecutiveBonus = 0
                }
                
                // Bonus for matching at start of word
                if targetIndex == 0 || !targetChars[targetIndex - 1].isLetter {
                    score += 15
                }
                
                lastMatchIndex = targetIndex
                queryIndex += 1
            }
            targetIndex += 1
        }
        
        // Return nil if not all query chars matched
        guard queryIndex == queryChars.count else { return nil }
        
        // Bonus for shorter targets (more precise match)
        score += max(0, 50 - targetChars.count)
        
        // Bonus for exact match
        if queryChars.count == targetChars.count {
            score += 50
        }
        
        return score
    }
    
    /// Simple boolean match check (for backward compatibility)
    static func match(query: String, target: String) -> Bool {
        return score(query: query, target: target) != nil
    }
}
