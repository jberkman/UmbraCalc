//
//  Kolonizing.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-10-07.
//  Copyright © 2015 jacob berkman.
//
//  Based on and includes portions of Moduler Kolonization System by RoverDude
//  https://github.com/BobPalmer/MKS/
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial
//  4.0 International License. To view a copy of this license, visit
//  http://creativecommons.org/licenses/by-nc/4.0/.
//

protocol Countable {

    var count: Int16 { get }

}

protocol ResourceConverting {

    var inputResources: [String: Double] { get }
    var outputResources: [String: Double] { get }

    var activeResourceConvertingCount: Int { get }

}

protocol ResourceConvertingCollectionType: ResourceConverting {

    var resourceConvertingCollection: AnyForwardCollection<ResourceConverting> { get }

}

protocol Crewing: ResourceConverting {

    var career: String? { get }
    var name: String? { get }
    var starCount: Int16 { get }

    var crewable: Crewable? { get }
    
}

protocol CrewingCollectionType {

    var crewingCollection: AnyForwardCollection<Crewing> { get }
    
}

protocol Kolonizing: ResourceConvertingCollectionType, CrewingCollectionType {

    var name: String? { get }
    var crewCapacity: Int { get }
    var livingSpaceCount: Int { get }
    var workspaceCount: Int { get }

}

protocol KolonizingCollectionType: Kolonizing {

    var kolonizingCollection: AnyForwardCollection<Kolonizing> { get }
    
}

// AKA Part
protocol Crewable: Kolonizing {

    var primarySkill: String? { get }
    var secondarySkill: String? { get }

    var crewBonus: Double { get }
    var efficiencyFactors: [String: Double] { get }
    var maxEfficiency: Double { get }

    // AKA Vessel
    var crewableCollection: CrewableCollectionType? { get }

}

// AKA Vessel
protocol CrewableCollectionType: KolonizingCollectionType {

    // AKA Kolony
    var containingKolonizingCollection: KolonizingCollectionType? { get }
    
}
