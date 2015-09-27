//
//  NamedType.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-27.
//  Copyright © 2015 jacob berkman. All rights reserved.
//

import Foundation

protocol NamedType: NSObjectProtocol {

    var name: String? { get }

}

protocol MutableNamedType: NamedType {

    var name: String? { get set }

}
