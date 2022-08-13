//
//  Generator.swift
//  DBGenerator
//
//  Created by Евгений Борисов on 11.08.2022.
//

import Foundation

import PostgresClientKit

class DataGenerator {

    var configuration = PostgresClientKit.ConnectionConfiguration()
    
    var preparedGames: Set<String>
    var preparedHeroes: Set<String>
    var preparedItems: Set<String>
    var preparedPlayers: Set<String>

    var savedDataId: [Tables : Int] = [:]

    var itemPopularity = [Int:Int]()

    init() {
        configuration.host = "localhost"
        configuration.database = "mobadb"
        configuration.user = "postgres"
        configuration.credential = .trust
        
        preparedGames = DataGenerator.getSetDataFrom(resourse: .games)
        preparedHeroes = DataGenerator.getSetDataFrom(resourse: .heroes)
        preparedItems = DataGenerator.getSetDataFrom(resourse: .items)
        preparedPlayers = DataGenerator.getSetDataFrom(resourse: .players)
        
        for table in Tables.allCases {
            savedDataId[table] = 0
        }
    }
    
    func generateDataTo(table: Tables, amountOfdata count: Int) {
        
        func generateData(by generate: () -> Void, max: Int) {
            assert(max >= count, "Can't generate that much data for \(table) table")
            
            for _ in 1...count {
                generate()
            }
        }
        
        switch table {
        case .game:
            generateData(by: generateDataGame, max: preparedGames.count)
        case .hero:
            generateData(by: generateDataHero, max: preparedHeroes.count)
        case .items:
            // Ensure the unique popularity of the item within the game
            for i in 1...savedDataId[.game]! {
                itemPopularity[i] = 1
            }
            generateData(by: generateDataItem, max: preparedItems.count)
        case .abilities:
            generateData(by: generateDataAbility, max: Int.max)
        case .characteristic:
            generateData(by: generateDataCharacteristic, max: savedDataId[.hero]! - savedDataId[.characteristic]!)
        case .popular_cosmetics:
            generateData(by: generateDataPopularCosmetics, max: Int.max)
        case .top_hero_players:
            generateData(by: generateDataHeroPlayer, max: preparedPlayers.count)
        case .item_hero_statistic:
            generateDataItemHero()
        }
        
    }
    
    private func generateDataGame() {
        let name = takeNameFrom(prepared: &preparedGames)
        let date = PostgresDate(year: Int.random(in: 1995...2021),
                                month: Int.random(in: 1...12),
                                day: Int.random(in: 1...28))
        savedDataId[.game]! += 1
        
        let command = "INSERT INTO game (game_name, release_date) VALUES ($1, $2);"
        
        executeCommand(command: command, parametres: [name, date])
    }
    
    private func generateDataHero() {
        let name = takeNameFrom(prepared: &preparedHeroes)
        let gamesId = Int.random(in: 1...savedDataId[.game]!)
        savedDataId[.hero]! += 1
        let attackType = ["ranged", "melee"].randomElement()
        let winrate = getWinrate()
        
        let command = "INSERT INTO hero (game_id, hero_name, attack_type, winrate) VALUES ($1, $2, $3, $4);"
        
        executeCommand(command: command, parametres: [gamesId, name, attackType, winrate])
    }
    
    
    private func generateDataItem() {
        let name = takeNameFrom(prepared: &preparedItems)
        let gamesId = Int.random(in: 1...savedDataId[.game]!)
        let price = Int.random(in: 1000...7000)
        let popularity = itemPopularity[gamesId]
        itemPopularity[gamesId] = itemPopularity[gamesId]! + 1
        savedDataId[.items]! += 1
        
        let winrate = getWinrate()
        
        let command = "INSERT INTO items (game_id, item_name, price, popularity, winrate) VALUES ($1, $2, $3, $4, $5);"
        
        executeCommand(command: command, parametres: [gamesId, name, price, popularity, winrate])
    }
    
    private func generateDataAbility() {
        
        let heroId = Int.random(in: 1...savedDataId[.hero]!)
        let name = randomString(length: Int.random(in: 4...8)) + " " + randomString(length: Int.random(in: 4...8))
        let spellType = ["active", "passive"].randomElement()
        
        let manacost: PostgresValue?
        let cooldown: PostgresValue?
        if spellType == "passive" {
            manacost = nil
            cooldown = nil
        } else {
            manacost = Int.random(in: 0...400).postgresValue
            cooldown = Double.random(in: 1...300).postgresValue
        }
        let description = randomString(length: Int.random(in: 1...70))
        
        savedDataId[.abilities]! += 1
        
        let command = "INSERT INTO abilities (hero_id, ability_name, ability_type, manacost, cooldown, description)"
        let values = " VALUES ($1, $2, $3, $4, $5, $6);"
        executeCommand(command: command + values, parametres: [heroId, name, spellType, manacost, cooldown, description])
        
        
    }
    
    private func generateDataCharacteristic() {
        
        savedDataId[.characteristic]! += 1
        
        let hero_id = savedDataId[.characteristic]
        let damage = Int.random(in: 20...150)
        let armor = Double.random(in: 0...10)
        let movespeed = Int.random(in: 50...400)
        let attackSpeed = Double.random(in: 0.5...4)
        
        let command = "INSERT INTO characteristic (hero_id, damage, armor, movespeed, attack_speed)"
        let values = " VALUES ($1, $2, $3, $4, $5);"
        
        executeCommand(command: command + values, parametres: [hero_id, damage, armor, movespeed, attackSpeed])
        
    }
    
    private func generateDataPopularCosmetics() {
        let heroId = Int.random(in: 1...savedDataId[.hero]!)
        let name = randomString(length: Int.random(in: 3...10)) + " " + randomString(length: Int.random(in: 3...15))
        let rare = ["common",
                    "uncommon",
                    "rare",
                    "mythical",
                    "legendary",
                    "immortal",
                    "arcana"].randomElement()
        let price = Double.random(in: 0.01...5000)
        savedDataId[.popular_cosmetics]! += 1
        
        let command = "INSERT INTO popular_cosmetics (hero_id, cosmetic_name, rare, price) VALUES ($1, $2, $3, $4);"
        
        executeCommand(command: command, parametres: [heroId, name, rare, price])
    }
    
    private func generateDataItemHero() {
        
        for heroId in 1...savedDataId[.hero]! {
            for itemId in 1...savedDataId[.items]! {
                
                let matches = Int.random(in: 0...20000)
                let winrate = getWinrate()
                
                let command = "INSERT INTO item_hero_statistic (hero_id, item_id, matches_cnt, winrate) VALUES ($1, $2, $3, $4);"
                
                executeCommand(command: command, parametres: [heroId, itemId, matches, winrate])
            }
        }
        
    }
    
    private func generateDataHeroPlayer() {
        let heroId = Int.random(in: 1...savedDataId[.hero]!)
        let name = takeNameFrom(prepared: &preparedPlayers)
        let matches = Int.random(in: 500...20000)
        let winrate = Double.random(in: 56...100)
        let kda = Double.random(in: 0...30)
        savedDataId[.top_hero_players]! += 1
        
        let command = "INSERT INTO top_hero_players (hero_id, nickname, matches_cnt, winrate, kda) VALUES ($1, $2, $3, $4, $5);"
        
        executeCommand(command: command, parametres: [heroId, name, matches, winrate, kda])
    }
    
    
    private func takeNameFrom(prepared: inout Set<String>) -> String {
        let name = prepared.randomElement()!
        prepared.remove(name)
        return name
    }
    
    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz"
        let random = String((0..<length).map{ _ in letters.randomElement()! })
        return random.prefix(1).uppercased() + random.dropFirst()
    }
    
    
    private func getWinrate() -> Double {
        Double.random(in: 0...100)
    }
    
    
    func rebase() {
        let command = try! String(contentsOfFile: ResoursesPaths.rebase.rawValue)
        for command in command.split(separator: ";") {
            executeCommand(command: command + ";")
        }
        
        // recreate function
        generator.executeCommand(command: """
        CREATE FUNCTION delete_different_games() RETURNS trigger AS $delete_different_games$
            DECLARE
            item_game integer;
            game_game integer;
            BEGIN
                item_game = (SELECT game_id
                             FROM items
                             WHERE item_id = NEW.item_id);
                game_game = (SELECT game_id
                             FROM hero
                             WHERE hero_id = NEW.hero_id);
                
                IF item_game <> game_game THEN
                    DELETE FROM item_hero_statistic WHERE hero_id = NEW.hero_id AND item_id = NEW.item_id;
                END IF;
                
                RETURN NEW;
            END;
        $delete_different_games$ LANGUAGE plpgsql;
        """)
        
        // recreate trigger
        
        generator.executeCommand(command: """
                CREATE TRIGGER delete_different_games AFTER INSERT ON item_hero_statistic
                    FOR EACH ROW EXECUTE PROCEDURE delete_different_games();
        """)
    }

    
    private func executeCommand(command text: String, parametres: [PostgresValueConvertible?]) {
        do {
            let connection = try PostgresClientKit.Connection(configuration: configuration)
            defer { connection.close() }

            let statement = try connection.prepareStatement(text: text)
            defer { statement.close() }
            
            let cursor = try statement.execute(parameterValues: parametres)
            do { cursor.close() }
        } catch {
            print("Something goes wrong") // better error handling goes here
        }
    }
    
    private func executeCommand(command text: String) {
        do {
            let connection = try PostgresClientKit.Connection(configuration: configuration)
            defer { connection.close() }

            let statement = try connection.prepareStatement(text: text)
            defer { statement.close() }
            
            let cursor = try statement.execute()
            do { cursor.close() }
        } catch {
            print("Something goes wrong")
        }
    }
    
    static func getSetDataFrom(resourse: ResoursesPaths) -> Set<String> {
        let text = try! String(contentsOfFile: resourse.rawValue)
        let array = text.split(separator: "\n").map { String($0) }
        return Set(array)
    }
    
    
    
}
