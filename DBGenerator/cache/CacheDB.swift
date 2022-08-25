//
//  CacheDB.swift
//  DBGenerator
//
//  Created by Евгений Борисов on 23.08.2022.
//

import Foundation
import PostgresClientKit

class CacheDB {
    
    var dataGenerator: DataGenerator
    var cache: LRU<Keys, [[PostgresValue]]>? = nil
    typealias HeroId = Int
    
    init(dataGenerator: DataGenerator) {
        self.dataGenerator = dataGenerator
    }
    
    init(dataGenerator: DataGenerator, cache: LRU<Keys, [[PostgresValue]]>) {
        self.dataGenerator = dataGenerator
        self.cache = cache
    }
    
    
    func getDataBy(heroId id: Keys) -> [[PostgresValue]] {
        
        
    switch id {
    case is Abilities:
        let heroId = id as! Abilities
        if let _ = cache {
            return getAbilityFromCache(heroId: heroId)
        }
        
        return getAbilityFromDB(heroId: heroId)
        
    case is Cosmetics:
        let heroId = id as! Cosmetics
        if let _ = cache {
            return getCosmeticsFromCache(heroId: heroId)
        }
        
        return getCosmeticsFromDB(heroId: heroId)
    case is TopPlayers:
        let heroId = id as! TopPlayers
        if let _ = cache {
            return getTopPlayersFromCache(heroId: heroId)
        }
        
        return getTopPlayersFromDB(heroId: heroId)
    default: return [[PostgresValue]]()
    }
    
      
    }
    
    
    func getAbilityFromCache(heroId: Abilities) -> [[PostgresValue]] {
        if let cursor = cache!.getValue(forKey: heroId) {
            return cursor
        }
        
        let abilities = getAbilityFromDB(heroId: heroId)
        
        cache!.setValue(value: abilities, forKey: heroId)
        
        return abilities
    }
    
    func getCosmeticsFromCache(heroId: Cosmetics) -> [[PostgresValue]] {
        if let cursor = cache!.getValue(forKey: heroId) {
            return cursor
        }
        
        let cosmetics = getCosmeticsFromDB(heroId: heroId)
        
        cache!.setValue(value: cosmetics, forKey: heroId)
        
        return cosmetics
    }
    
    func getCosmeticsFromDB(heroId: Cosmetics) -> [[PostgresValue]] {
        let command = """
        SELECT *
        FROM popular_cosmetics
        where hero_id = $1
        """
        return dataGenerator.executeCommand(command: command, parametres: [heroId.heroId])!
    }
    
    func getTopPlayersFromCache(heroId: TopPlayers) -> [[PostgresValue]] {
        if let cursor = cache!.getValue(forKey: heroId) {
            return cursor
        }
        
        let topPlayers = getTopPlayersFromDB(heroId: heroId)
        
        cache!.setValue(value: topPlayers, forKey: heroId)
        
        return topPlayers
    }
    
    func getTopPlayersFromDB(heroId: TopPlayers) -> [[PostgresValue]] {
        let command = """
        SELECT *
        FROM top_hero_players
        where hero_id = $1
        """
        return dataGenerator.executeCommand(command: command, parametres: [heroId.heroId])!
    }
    
    func getAbilityFromDB(heroId: Abilities) -> [[PostgresValue]] {
        let command = """
        SELECT *
        FROM abilities
        where hero_id = $1
        """
        return dataGenerator.executeCommand(command: command, parametres: [heroId.heroId])!
    }
    
    
    func updateCosmeticPriceBy(cosmeticId id: Int, price: Double) {
       
        let command = """
        UPDATE popular_cosmetics
        SET price = $2
        WHERE cosmetic_id = $1
        """
        
        dataGenerator.executeCommand(command: command, parametres: [id, price])
        
        if let cache = cache {
            let command = """
            SELECT hero_id
            FROM popular_cosmetics
            WHERE cosmetic_id = $1
            """
            
            let result = dataGenerator.executeCommand(command: command, parametres: [id])
            if let result = result {
                let heroId = try! result[0][0].int()
                
                if let _ = cache.getValue(forKey: Cosmetics(heroId: heroId)) {
                    cache.setValue(value: getCosmeticsFromDB(heroId: Cosmetics(heroId: heroId)), forKey: Cosmetics(heroId: heroId))
                }
                
            }
        }
    }
    
    func updateWinratePlayersBy(playerId: Int, winrate: Double) {
        
        let command = """
        UPDATE top_hero_players
        SET winrate = $2
        WHERE player_id = $1
        """
        
        dataGenerator.executeCommand(command: command, parametres: [playerId, winrate])
        
        if let cache = cache {
            let command = """
            SELECT hero_id
            FROM top_hero_players
            WHERE player_id = $1
            """
            
            let result = dataGenerator.executeCommand(command: command, parametres: [playerId])
            if let result = result {
                if result.isEmpty {
                    return
                }
                let heroId = try? result[0][0].int()
                
                if let heroId = heroId {
                    if let _ = cache.getValue(forKey: TopPlayers(heroId: heroId)) {
                        cache.setValue(value: getTopPlayersFromDB(heroId: TopPlayers(heroId: heroId)), forKey: TopPlayers(heroId: heroId))
                    }
                }
                
            }
        }
    }
    
    func deleteHeroFromTopPlayersBy(heroId: Int) {
        let command = """
        DELETE FROM top_hero_players
        WHERE hero_id = $1
        """
        
        dataGenerator.executeCommand(command: command, parametres: [heroId])
        
        if let cache = cache {
            let key = TopPlayers(heroId: heroId)
            if let _ = cache.getValue(forKey: key) {
                cache.remove(node: cache.nodeDictionary[key]!)
            }
            
        }
    }
    
}

