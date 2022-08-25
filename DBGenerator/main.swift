import PostgresClientKit


var generator = DataGenerator()

generator.rebase()
generator.generateDataTo(table: .game, amountOfdata: 5)
generator.generateDataTo(table: .hero, amountOfdata: 400)
generator.generateDataTo(table: .abilities, amountOfdata: 10000)
generator.generateDataTo(table: .popular_cosmetics, amountOfdata: 10000)
generator.generateDataTo(table: .top_hero_players, amountOfdata: 10000)

let lru = LRU<Keys, [[PostgresValue]]>(capacity: 300)
let lru2 = LRU<Keys, [[PostgresValue]]>(capacity: 50)

var cache = CacheDB(dataGenerator: generator, cache: lru)
var cache2 = CacheDB(dataGenerator: generator, cache: lru2)
var cache3 = CacheDB(dataGenerator: generator)

//testSelectAndUpdateCosmetics(countOfSelects: 10000, countOfUpdate: 1000, cache: cache)
//print("\n---------------------------\n")
//testSelectAndUpdateCosmetics(countOfSelects: 10000, countOfUpdate: 1000, cache: cache2)
//print("\n---------------------------\n")
//testSelectAndUpdateCosmetics(countOfSelects: 10000, countOfUpdate: 1000, cache: cache3)


testSelectUpdateDeleteTopPlayers(selectCount: 10000, deleteCount: 1000, updateCount: 1000, cache: cache)
print("\n---------------------------\n")
testSelectUpdateDeleteTopPlayers(selectCount: 10000, deleteCount: 1000, updateCount: 1000, cache: cache2)
print("\n---------------------------\n")
testSelectUpdateDeleteTopPlayers(selectCount: 10000, deleteCount: 1000, updateCount: 1000, cache: cache3)
