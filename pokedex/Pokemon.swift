//
//  Pokemon.swift
//  pokedex
//
//  Created by Le Quang Chinh on 10/1/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

import Foundation
import Alamofire

class Pokemon {
    
    private var _name: String!
    private var _pokedexId: Int!
    private var _description: String!
    private var _type: String!
    private var _defense: String!
    private var _height: String!
    private var _weight: String!
    private var _attack: String!
    private var _nextEvolutionTxt: String!
    private var _nextEvolutionId: String!
    private var _nextEvolutionLvl:String!
    private var _pokemonUrl: String!
    
    var pokemonUrl: String {
        if _pokemonUrl == nil {
            _pokemonUrl = ""
        }
        return _pokemonUrl
    }
    
    var nextEvolutionLvl: String {
        
        if _nextEvolutionLvl == nil {
            _nextEvolutionLvl = ""
        }
        return _nextEvolutionLvl
    }
    
    var nextEvolutionId: String {
        if _nextEvolutionId == nil{
            _nextEvolutionId = ""
        }
        return _nextEvolutionId
    }
    
    var nextEvolutionTxt: String {
        if _nextEvolutionTxt == nil {
            _nextEvolutionTxt = ""
        }
        return _nextEvolutionTxt
    }
    
    var attack: String{
        if _attack == nil {
            _attack = ""
        }
        return _attack
    }
    
    var weight: String {
        if _weight == nil {
            _weight = ""
        }
        return _weight
    }
    
    var height: String {
        if _height == nil {
            _height = ""
        }
        return _height
    }
    
    var defense: String {
        if _defense == nil {
            _defense = ""
        }
        return _defense
    }
    
    var type:String {
        if _type == nil {
            _type = ""
        }
        return _type
    }
    
    var description: String {
        if _description == nil {
            _description = ""
        }
        return _description
    }
    
    var name: String {
        return _name
    }
    
    var pokedexId: Int {
        return _pokedexId
    }
    
    init(name: String, pokedexId: Int) {
        self._name = name
        self._pokedexId = pokedexId
        //_pokemonUrl = "\(URL_BASE)\(URL_POKEMON)\(self._pokedexId)/"
        
        self._pokemonUrl = "\(URL_BASE)\(URL_POKEMON)\(String(self._pokedexId))/"
        
    }
    
    func downloadPokemonDetails(completed: @escaping DownloadComplete) {
        let url = URL(string: self._pokemonUrl)!
        
        Alamofire.request(url).responseJSON { response in // method defaults to `.get`
            
            if let dict = response.result.value as? Dictionary<String, AnyObject> {
                
                if let weight = dict["weight"] as? String {
                    self._weight = weight
                }
                
                if let height = dict["height"] as? String {
                    self._height = height
                }
                
                if let attack = dict["attack"] as? Int {
                    self._attack = String(attack)
                }
                
                if let defense = dict["defense"] as? Int {
                    self._defense = String(defense)
                }
                
                if let types = dict["type"] as? [Dictionary<String, String>], types.count > 0 {
                    
                    if let name = types[0]["name"] {
                        self._type = name.capitalized
                    }
                    
                    if types.count > 1 {
                        
                        for x in 1 ..< types.count {
                            if let name = types[x]["name"] {
                                self._type! += "/\(name.capitalized)"
                            }
                        }
                    }
                    
                } else {
                    self._type = ""
                }
                
                if let desArr = dict["descriptions"] as? [Dictionary<String, String>], desArr.count > 0 {
                    if let url = desArr[0]["resource_uri"] {
                        let nsurl = URL(string: "\(URL_BASE)\(url)")!
                        Alamofire.request(nsurl).responseJSON { response in
                            
                            let desResult = response.result
                            if let descDict = desResult.value as? Dictionary<String, AnyObject> {
                                
                                if let description = descDict["description"] as? String {
                                    self._description = description
                                }
                            
                            }
                            
                            
                        }
                        
                        completed()
                        
                    }
                    
                } else {
                    self._description = ""
                }
            
                if let evolutions = dict["evolutions"] as? [Dictionary<String, AnyObject>], evolutions.count > 0 {
                    
                    if let to = evolutions[0]["to"] as? String {
                        //Can't support mega pokemon right now but
                        //api still has mega data
                        if to.range(of: "mega") == nil {
                            if let uri = evolutions[0]["resource_uri"] as? String {
                                let newStr = uri.replacingOccurrences(of: "/api/v1/pokemon/", with: "")
                                
                                let num = newStr.replacingOccurrences(of: "/", with: "")
                                
                                self._nextEvolutionId = num
                                self._nextEvolutionTxt = to
                                
                                if let lvl = evolutions[0]["level"] as? Int {
                                    self._nextEvolutionLvl = String(lvl)
                                }
                            
                            }
                        
                        }
                    
                    }
                
                }
                
                
            }
        }
        
    }

}
