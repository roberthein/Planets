//
//  PlanetName.swift
//  Planets!
//
//  Created by Robert-Hein Hooijmans on 09/12/16.
//  Copyright © 2016 Robert-Hein Hooijmans. All rights reserved.
//

import Foundation

typealias PlanetName = String
typealias Total = Int
typealias Record = (Total, [Syllable: Total])
typealias Mapping = [Syllable: Record]

enum Syllable: Hashable, Equatable {
    case Vowel(Character)
    case Suffix
    
    var hashValue: Int {
        switch self {
        case let .Vowel(string): return string.hashValue
        case .Suffix: return "".hashValue
        }
    }
}

func == (lhs: Syllable, rhs: Syllable) -> Bool {
    switch (lhs, rhs) {
    case let (.Vowel(l), .Vowel(r)):
        return l == r
    case (.Suffix, .Suffix):
        return true
    default:
        return false
    }
}

public struct PlanetNameGenerator {
    
    private var mapping: Mapping
    private var vowels = [Syllable]()
    
    public init() {
        mapping = PlanetNameGenerator.mappingFrom(self.existingPlanetNames)
        vowels = self.existingPlanetNames.filter { $0.characters.count != 0 }.map { .Vowel($0.characters.first!) }
    }
    
    private static func mappingFrom(_ planetNames: Set<PlanetName>) -> Mapping {
        var mapping = Mapping()
        
        for planetName in planetNames {
            let syllables = planetName.syllables()
            
            for (current, next) in zip(syllables, syllables[1..<syllables.endIndex]) {
                if let (totalCount, records) = mapping[current] {
                    var records = records
                    let total = records[next] ?? 0
                    records[next] = total + 1
                    mapping[current] = (totalCount + 1, records)
                }
                else {
                    mapping[current] = (1, [next: 1])
                }
            }
        }
        
        return mapping
    }
    
    func randomStartingSyllable() -> Syllable {
        let randomIndex = Int.random(lower: 0, upper: vowels.count)
        return vowels[randomIndex]
    }
    
    func nextSyllable(for syllable: Syllable) -> Syllable {
        let (totalCount, records) = mapping[syllable]!
        let randomValue = Int.random(lower: 0, upper: Int(totalCount))
        
        var sum: Int = 0
        for (syllable, total) in records {
            sum = sum + Int(total)
            if randomValue < sum {
                return syllable
            }
        }
        
        fatalError("ERROR: RandomValue should never exceed total!")
    }
    
    func generatePlanetName() -> PlanetName {
        var syllables = [Syllable]()
        var syllable = randomStartingSyllable()
        while syllable != .Suffix {
            syllables.append(syllable)
            syllable = nextSyllable(for: syllable)
        }
        
        return planetNameFromSyllables(syllables: syllables)
    }
    
    private func planetNameFromSyllables(syllables: [Syllable]) -> PlanetName {
        return syllables.reduce("") { planetName, syllable in
            switch syllable {
            case let .Vowel(character):
                return planetName + String(character)
            case .Suffix:
                return planetName
            }
        }
    }
    
    var existingPlanetNames: Set<PlanetName> = {
        return ["Apokolips",
                "Avalon",
                "Bismoll",
                "Bizarro World",
                "Citadel",
                "Competalia",
                "Daxam",
                "Gemworld",
                "H'lven",
                "Korugar",
                "Krypton",
                "Mogo",
                "Multiverse",
                "Naltor",
                "New Genesis",
                "Qward",
                "Rann",
                "Starhaven",
                "Takron-Galtos",
                "Tamaran",
                "Thanagar",
                "Urgrund",
                "Warworld",
                "Xolnar"]
    }()
}
