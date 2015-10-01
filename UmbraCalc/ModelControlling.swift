//
//  ModelControlling.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-10-01.
//  Copyright © 2015 jacob berkman.
//
//  Based on and includes portions of Moduler Kolonization System by RoverDude
//  https://github.com/BobPalmer/MKS/
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial
//  4.0 International License. To view a copy of this license, visit
//  http://creativecommons.org/licenses/by-nc/4.0/.
//

protocol ModelControlling {
    typealias Model
    var model: Model? { get set }
}

protocol ModelListControlling {
    typealias Model
    var models: [Model] { get }
}

protocol SelectableModelList {
    typealias Model
    var selectedModel: Model? { get set }
}

protocol MultipleSelectableModelList {
    typealias Model: Hashable
    var maximumSelectionCount: Int { get set }
    var selectedModels: Set<Model> { get set }
}
