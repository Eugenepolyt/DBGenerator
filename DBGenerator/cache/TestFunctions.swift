//
//  TestFunctions.swift
//  DBGenerator
//
//  Created by Евгений Борисов on 23.08.2022.
//
import Foundation

func getDifferenceTimeInMks(start: DispatchTime, end: DispatchTime) -> Double {
    let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
    let timeInterval = Double(nanoTime) / 1_000
    return timeInterval
}


func TestSelectAbilities(countOfSelects count: Int, cache: CacheDB) {
    
    var maxTime = 0.0
    var minTime = Double.greatestFiniteMagnitude
    
    var maxHeroId = cache.dataGenerator.savedDataId[.hero]!
    
    let allStartTime = DispatchTime.now()
    for _ in 1...count {
        let start = DispatchTime.now()
        cache.getDataBy(heroId: Abilities(heroId: Int.random(in: 1...maxHeroId)))
        let end = DispatchTime.now()
        let difference = getDifferenceTimeInMks(start: start, end: end)
        
        if difference > maxTime {
            maxTime = difference
        }
        
        if difference < minTime {
            minTime = difference
        }
    }
    
    let allEndTime = DispatchTime.now()
    
    let timePassed = getDifferenceTimeInMks(start: allStartTime, end: allEndTime)
    let averageTime = timePassed / Double(count)
    
    if let cache = cache.cache {
        print ("""
        Testing \(count) selects from abilities
        With a CacheDB cache of \(cache.capacity) items
        Sum time of all operations: \(timePassed)
        Average time of all operations: \(averageTime)
        Min time for 1 operation: \(minTime)
        Max time for 1 operation: \(maxTime)
        """)
    } else {
        print ("""
        Testing \(count) selects from abilities
        Without cache
        Sum time of all operations: \(timePassed)
        Average time of all operations: \(averageTime)
        Min time for 1 operation: \(minTime)
        Max time for 1 operation: \(maxTime)
        """)
    }
    
}

func testSelectAndUpdateCosmetics(countOfSelects: Int, countOfUpdate: Int, cache: CacheDB) {
    
    var maxTimeUpd = 0.0
    var minTimeUpd = Double.greatestFiniteMagnitude
    var maxHeroId = cache.dataGenerator.savedDataId[.hero]!
    var maxCosmeticsId = cache.dataGenerator.savedDataId[.popular_cosmetics]!
    var maxTimeSelect = 0.0
    var minTimeSelect = Double.greatestFiniteMagnitude
    
    var updateCount = 0
    var selectCount = 0
    
    var selectAllTime = 0.0
    var updateAllTime = 0.0
    
    for _ in 1...(countOfSelects + countOfUpdate) {
        
        if selectCount != countOfSelects {
            let start = DispatchTime.now()
            cache.getDataBy(heroId: Cosmetics(heroId: Int.random(in: 1...maxHeroId)))
            let end = DispatchTime.now()
            
            let difference = getDifferenceTimeInMks(start: start, end: end)
            
            if difference > maxTimeSelect {
                maxTimeSelect = difference
            }
            
            if difference < minTimeSelect {
                minTimeSelect = difference
            }
            
            selectAllTime += difference
            selectCount += 1
        }
        
        if updateCount != countOfUpdate {
            
            let start = DispatchTime.now()
            cache.updateCosmeticPriceBy(cosmeticId: Int.random(in: 1...maxCosmeticsId), price: Double.random(in: 1...4000))
            let end = DispatchTime.now()
            
            let difference = getDifferenceTimeInMks(start: start, end: end)
            
            if difference > maxTimeUpd {
                maxTimeUpd = difference
            }
            
            if difference < minTimeUpd {
                minTimeUpd = difference
            }
            
            updateAllTime += difference
            updateCount += 1
        }
    }
    
    
    let averageSelect = selectAllTime / Double(countOfSelects)
    let averageUpdate = updateAllTime / Double(countOfUpdate)
    
    if let cache = cache.cache {
        print ("""
        With a CacheDB cache of \(cache.capacity) items:
        
        \(countOfSelects) SELECT statistics:
        Sum time of all operations: \(selectAllTime)
        Average time of all operations: \(averageSelect)
        Min time for 1 operation: \(minTimeSelect)
        Max time for 1 operation: \(maxTimeSelect)
        
        \(countOfUpdate) UPDATE statistics:
        Sum time of all operations: \(updateAllTime)
        Average time of all operations: \(averageUpdate)
        Min time for 1 operation: \(minTimeUpd)
        Max time for 1 operation: \(maxTimeUpd)
        """)
    } else {
        print ("""
        Without cache:
        
        \(countOfSelects) SELECT statistics:
        Sum time of all operations: \(selectAllTime)
        Average time of all operations: \(averageSelect)
        Min time for 1 operation: \(minTimeSelect)
        Max time for 1 operation: \(maxTimeSelect)
        
        \(countOfUpdate) UPDATE statistics:
        Sum time of all operations: \(updateAllTime)
        Average time of all operations: \(averageUpdate)
        Min time for 1 operation: \(minTimeUpd)
        Max time for 1 operation: \(maxTimeUpd)
        """)
    }
}

func testSelectUpdateDeleteTopPlayers(selectCount: Int, deleteCount: Int, updateCount: Int, cache: CacheDB) {
    
    
    var minMaxTime: (selectMin: Double,
                     selectMax: Double,
                     updateMin: Double,
                     updateMax: Double,
                     deleteMin: Double,
                     deleteMax: Double) = (Double.greatestFiniteMagnitude, 0.0, Double.greatestFiniteMagnitude, 0.0, Double.greatestFiniteMagnitude, 0.0)
    
    var delete = 0
    var select = 0
    var update = 0
    
    var selectAllTime = 0.0
    var updateAllTime = 0.0
    var deleteAllTime = 0.0
    
    var maxHeroId = cache.dataGenerator.savedDataId[.hero]!
    var maxPlayerId = cache.dataGenerator.savedDataId[.top_hero_players]!
    
    for _ in 1...(selectCount + deleteCount + updateCount) {
        
        if select != selectCount {
            let start = DispatchTime.now()
            cache.getDataBy(heroId: TopPlayers(heroId: Int.random(in: 1...maxHeroId)))
            let end = DispatchTime.now()
            
            let difference = getDifferenceTimeInMks(start: start, end: end)
            
            if difference > minMaxTime.selectMax {
                minMaxTime.selectMax = difference
            }
            
            if difference < minMaxTime.selectMin {
                minMaxTime.selectMin = difference
            }
            
            selectAllTime += difference
            select += 1
        }
        
        if update != updateCount {
            
            let start = DispatchTime.now()
            cache.updateWinratePlayersBy(playerId: Int.random(in: 1...maxPlayerId), winrate: Double.random(in: 56...99))
            let end = DispatchTime.now()
            
            let difference = getDifferenceTimeInMks(start: start, end: end)
            
            if difference > minMaxTime.updateMax {
                minMaxTime.updateMax = difference
            }
            
            if difference < minMaxTime.updateMin {
                minMaxTime.updateMin = difference
            }
            
            updateAllTime += difference
            update += 1
            
        }
        
        if delete != deleteCount {
            let start = DispatchTime.now()
            cache.deleteHeroFromTopPlayersBy(heroId: Int.random(in: 1...maxHeroId))
            let end = DispatchTime.now()
            
            let difference = getDifferenceTimeInMks(start: start, end: end)
            
            if difference > minMaxTime.deleteMax {
                minMaxTime.deleteMax = difference
            }
            
            if difference < minMaxTime.deleteMin {
                minMaxTime.deleteMin = difference
            }
            
            deleteAllTime += difference
            delete += 1
        }
        
    }
    
    
    let averageSelect = selectAllTime / Double(selectCount)
    let averageUpdate = updateAllTime / Double(updateCount)
    let averageDelete = deleteAllTime / Double(deleteCount)
    
    
    if let cache = cache.cache {
        print ("""
        With a CacheDB cache of \(cache.capacity) items:
        
        \(selectCount) SELECT statistics:
        Sum time of all operations: \(selectAllTime)
        Average time of all operations: \(averageSelect)
        Min time for 1 operation: \(minMaxTime.selectMin)
        Max time for 1 operation: \(minMaxTime.selectMax)
        
        \(updateCount) UPDATE statistics:
        Sum time of all operations: \(updateAllTime)
        Average time of all operations: \(averageUpdate)
        Min time for 1 operation: \(minMaxTime.updateMin)
        Max time for 1 operation: \(minMaxTime.updateMax)
        
        \(deleteCount) DELETE statistics
        Sum time of all operations: \(deleteAllTime)
        Average time of all operations: \(averageDelete)
        Min time for 1 operation: \(minMaxTime.deleteMin)
        Max time for 1 operation: \(minMaxTime.deleteMax)
        """)
    } else {
        print ("""
        Without cache:
        
        \(selectCount) SELECT statistics:
        Sum time of all operations: \(selectAllTime)
        Average time of all operations: \(averageSelect)
        Min time for 1 operation: \(minMaxTime.selectMin)
        Max time for 1 operation: \(minMaxTime.selectMax)
        
        \(updateCount) UPDATE statistics:
        Sum time of all operations: \(updateAllTime)
        Average time of all operations: \(averageUpdate)
        Min time for 1 operation: \(minMaxTime.updateMin)
        Max time for 1 operation: \(minMaxTime.updateMax)
        
        \(deleteCount) DELETE statistics
        Sum time of all operations: \(deleteAllTime)
        Average time of all operations: \(averageDelete)
        Min time for 1 operation: \(minMaxTime.deleteMin)
        Max time for 1 operation: \(minMaxTime.deleteMax)
        """)
    }

}
