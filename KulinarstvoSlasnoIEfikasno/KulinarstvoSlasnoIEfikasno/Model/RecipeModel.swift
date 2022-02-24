//
//  RecipeModel.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 31.10.21.
//

import Foundation
import SwiftUI

public class Recipe : Codable {
    
    var name: String
    var prepTime: Int // In minutes
    
    var ingredients: [Ingredient]
    var steps: [String]
    
    var isFavorite: Bool?
    var isMyRecipe: Bool?
    
    var category: RecipeCategory?
    
    var numOfPersons: Int = 0
    
    var stringIngredients: [String] {
        var stringIngredients: [String] = []
        for ingredient in self.ingredients {
            let tmp = ingredient.quantity.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", ingredient.quantity) : String(ingredient.quantity)
            let stringIngredient = tmp + " \(ingredient.measureUnit) \(ingredient.ingredient)"
            stringIngredients.append(stringIngredient)
        }
        return stringIngredients
    }
    
    var url: URL? {
        return URL(string: "kulinarstvoslasnoiefikasno://" + name.replacingOccurrences(of: " ", with: ""))
    }
    
    var imageName: String {
        return name
    }
    
    init(name: String, prepTime: Int, ingredients: [Ingredient], steps: [String], isFavorite: Bool? = false, isMyRecipe: Bool? = false, category: RecipeCategory, numOfPersons: Int = 0) {
        self.name = name
        self.prepTime = prepTime
        self.ingredients = ingredients
        self.steps = steps
        self.isFavorite = isFavorite
        self.isMyRecipe = isMyRecipe
        self.category = category
        self.numOfPersons = numOfPersons
    }
}

public struct Ingredient : Codable {
    var quantity: Double
    var measureUnit: String
    var ingredient: String
    
    init(quantity: Double, measureUnit: String, ingredient: String) {
        self.quantity = quantity
        self.measureUnit = measureUnit
        self.ingredient = ingredient
    }
}

public enum RecipeCategory : Int, Codable, CaseIterable {
    case coldSideDish = 0, warmSideDish, mainDish, snack, drink, soup, dessert, salad, bread
}

protocol RecipeModelDelegate : AnyObject {
    func recipeModelDidChange(recipes: [Recipe])
}

class RecipeModel {
    
    weak var delegate: RecipeModelDelegate?

    static let testData = [
        Recipe(name: "Omlet", prepTime: 15, ingredients: [
            Ingredient(quantity: 3, measureUnit: "komada", ingredient: "jaja"),
            Ingredient(quantity: 20, measureUnit: "grama", ingredient: "sira"),
            Ingredient(quantity: 1, measureUnit: "kasicica", ingredient: "persun")
        ], steps: [
            "Izmutiti jaja sitno i brzo", "Dodati sitno", "Lorem ipsum za proveru duzine i sirine opisa postupka", "Sipati u tiganj i prziti", "Proba", "priprema", "7 korak po redu",
            "Izmutiti jaja sitno i brzo", "Dodati sitno", "Lorem ipsum za proveru duzine i sirine opisa postupka", "Sipati u tiganj i prziti", "Proba", "priprema", "7 korak po redu",
            "Izmutiti jaja sitno i brzo", "Dodati sitno", "Lorem ipsum za proveru duzine i sirine opisa postupka", "Sipati u tiganj i prziti", "Proba", "priprema", "7 korak po redu"
        ], category: .warmSideDish),
        Recipe(name: "Spagete karbonara", prepTime: 45, ingredients: [], steps: [], category: .mainDish),
        Recipe(name: "Pirinac", prepTime: 20,
               ingredients: [Ingredient(quantity: 200, measureUnit: "grama", ingredient: "pirinac"),
                             Ingredient(quantity: 2, measureUnit: "kasike", ingredient: "zejtin"),
                             Ingredient(quantity: 1, measureUnit: "prstohvat", ingredient: "soli"),
                             Ingredient(quantity: 400, measureUnit: "mililitra", ingredient: "voda")],
               steps: [ "Oprati pirinac", "Dodati vodu", "Dodati zejtin", "Dodati so", "Kuvati 20ak minuta"], category: .warmSideDish),
        Recipe(name: "Mesano povrce", prepTime: 25, ingredients: [], steps: [], category: .warmSideDish),
        Recipe(name: "Sendvic", prepTime: 5, ingredients: [], steps: [], category: .bread),
        Recipe(name: "Cezar salata", prepTime: 75,
               ingredients: [Ingredient(quantity: 400, measureUnit: "grama", ingredient: "slanina"), Ingredient(quantity: 1, measureUnit: "kilogram", ingredient: "pilece belo"), Ingredient(quantity: 2, measureUnit: "glavice", ingredient: "zelena salata"), Ingredient(quantity: 400, measureUnit: "grama", ingredient: "cheri paradajz"), Ingredient(quantity: 6, measureUnit: "kriski", ingredient: "hleba"), Ingredient(quantity: 600, measureUnit: "grama", ingredient: "cezar preliv")],
               steps: ["Iseckati slaninu na kockice", "Proprziti slaninu", "Iseckati pilece belo na kockice", "Proprziti pilece belo", "Iseckati hleba na kockice", "Umedjuvremenu nacepkati listove zelene salate u ciniju", "Naseci cheri paradajz i dodati u ciniju", "Kada hleb zapece skloniti sa ringle i sve dodati u ciniju", "Dodati cezar preliv", "Promesati sve i uzivati"],
               isFavorite: true, isMyRecipe: true, category: .salad, numOfPersons: 6)
    ]

    static var myTestData = [
        Recipe(name: "Omlet", prepTime: 15, ingredients: [
            Ingredient(quantity: 3, measureUnit: "komada", ingredient: "jaja"),
            Ingredient(quantity: 20, measureUnit: "grama", ingredient: "sira")
        ], steps: [
            "Izmutiti jaja", "Dodati sitno seckan paradajz", "Sipati u tiganj i prziti"
        ], category: .warmSideDish),
        Recipe(name: "Sendvic", prepTime: 5, ingredients: [], steps: [
            "Uzeti jedno parce hleba", "Staviti pecenicu na njega", "Staviti kackavalj preko", "Staviti drugo parce hleba"
        ], category: .snack)
    ]
    
    private var recipes: [Recipe] = []
    var isLoaded = false
    
    func loadFile() {
        do {
            let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Datafeed.shared.kAppGroup) //FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let fileURL = dir?.appendingPathComponent("RecipesData.json")
            
            //If file exist in document directory
            if let data = try? Data(contentsOf: fileURL!) {
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let recipes = jsonResult["recipes"] as? [Any] {
                    for recipe in recipes {
                        self.recipes.append(self.parseRecipe(recipe: recipe))
                    }
                }
                self.delegate?.recipeModelDidChange(recipes: self.recipes)
                self.isLoaded = true
            }
            //If file exist in local
            else if let path = Bundle.main.path(forResource: "RecipesData", ofType: "json") {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let recipes = jsonResult["recipes"] as? [Any] {
                    for recipe in recipes {
                        self.recipes.append(self.parseRecipe(recipe: recipe))
                    }
                }
                self.delegate?.recipeModelDidChange(recipes: self.recipes)
                self.isLoaded = true
            }
        } catch {
            print("File could not be loaded")
        }
    }
    
    func parseRecipe(recipe: Any) -> Recipe {
        guard let r = recipe as? [String:Any] else {
            return Recipe(name: "", prepTime: 0, ingredients: [], steps: [], isFavorite: false, category: .snack)
        }
        
        let rec = Recipe(name: "", prepTime: 0, ingredients: [], steps: [], isFavorite: false, category: .snack)
        for recipeKey in r.keys {
            switch recipeKey {
            case "name":
                rec.name = (r["name"] as? String ?? "")
            case "prepTime":
                rec.prepTime = (r["prepTime"] as? Int ?? 0)
            case "ingredients":
                let stringIngredients = (r["ingredients"] as? [String] ?? [])
                var ingredients: [Ingredient] = []
                for stringIngredient in stringIngredients {
                    let parts = stringIngredient.split(separator: "_")
                    if parts.count != 3 {
                        continue
                    }
                    let quantity = parts[0]
                    let measureUnit = parts[1]
                    let ingredient = parts[2]
                    ingredients.append(Ingredient(quantity: Double(quantity) ?? 0, measureUnit: String(measureUnit), ingredient: String(ingredient)))
                }
                rec.ingredients = ingredients
            case "steps":
                rec.steps = (r["steps"] as? [String] ?? [])
            case "isFavorite":
                rec.isFavorite = (r["isFavorite"] as? Bool ?? false)
            case "isMyRecipe":
                rec.isMyRecipe = (r["isMyRecipe"] as? Bool ?? false)
            case "category":
                rec.category = RecipeCategory(rawValue: (r["category"] as? Int ?? 0))
            case "numOfPersons":
                rec.numOfPersons = (r["numOfPersons"] as? Int ?? 0)
            default:
                ()
            }
        }
        return rec
    }
}

protocol DatafeedDelegate : AnyObject {
    func recipesDataParsed()
}

class Datafeed {
    
    static let shared = Datafeed()
    
    private init() {
//        self.recipes = []
    }
    
    lazy var recipeModel: RecipeModel = {
        var model = RecipeModel()
        model.delegate = self
        return model
    }()
    
    weak var delegate: DatafeedDelegate?
    
    var recipes: [Recipe] = [] {
        didSet {
            self.delegate?.recipesDataParsed()
        }
    }
    
    var favRecipes: [Recipe] {
        get {
            let filtered = self.recipes.filter {
                $0.isFavorite ?? false
            }
            return filtered
        }
    }
    
    var myRecipes: [Recipe] {
        get {
            let filtered = self.recipes.filter {
                $0.isMyRecipe ?? false
            }
            return filtered
        }
    }
    
    let kAppGroup = "group.com.kulinarstvo_slasno_i_efikasno"
}

extension Datafeed : RecipeModelDelegate {
    func recipeModelDidChange(recipes: [Recipe]) {
        self.recipes = recipes
    }
    
}

class AppTheme {
    static let backgroundUniversalGreen = UIColor(displayP3Red: 4/255, green: 110/255, blue: 75/255, alpha: 1)
    static let textUniversalGreen = UIColor(displayP3Red: 190/255, green: 255/255, blue: 249/255, alpha: 1)
    
    static func setTextColor() -> UIColor {
        return UITraitCollection.current.userInterfaceStyle == .dark ? AppTheme.textUniversalGreen : AppTheme.backgroundUniversalGreen
    }
    
    static func setBackgroundColor() -> UIColor {
        return UITraitCollection.current.userInterfaceStyle == .dark ? AppTheme.backgroundUniversalGreen : AppTheme.textUniversalGreen
    }
}
