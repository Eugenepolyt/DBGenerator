//
//  Keys.swift
//  DBGenerator
//
//  Created by Евгений Борисов on 23.08.2022.
//

class Keys: Hashable, Comparable {
    
    var heroId: Int
    
    init(heroId: Int) {
        self.heroId = heroId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(heroId)
    }

    static func == (lhs: Keys, rhs: Keys) -> Bool {
        return lhs.heroId == rhs.heroId
    }
    
    static func < (lhs: Keys, rhs: Keys) -> Bool {
            return lhs.heroId < rhs.heroId
        }
}


class Abilities: Keys {}
class Cosmetics: Keys {}
class TopPlayers: Keys {}


