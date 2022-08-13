
import Foundation



var generator = DataGenerator()

generator.rebase()
generator.generateDataTo(table: .game, amountOfdata: 5)
generator.generateDataTo(table: .hero, amountOfdata: 20)
generator.generateDataTo(table: .items, amountOfdata: 20)
generator.generateDataTo(table: .abilities, amountOfdata: 20)
generator.generateDataTo(table: .characteristic, amountOfdata: 20)
generator.generateDataTo(table: .popular_cosmetics, amountOfdata: 20)
generator.generateDataTo(table: .top_hero_players, amountOfdata: 100)
generator.generateDataTo(table: .item_hero_statistic, amountOfdata: 0)


