//
//  CrewFetchedDataSource.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-27.
//  Copyright © 2015 jacob berkman. All rights reserved.
//

import UIKit

class CrewFetchedDataSource<Entity: Crew, Cell: UITableViewCell>: NamedEntityFetchedDataSource<Entity, Cell> {

    override init() {
        super.init()
        let namedConfigureCell = configureCell
        configureCell = { [weak self] (cell: Cell, crew: Entity) in
            namedConfigureCell?(cell: cell, entity: crew)
            guard self != nil else { return }
            let starString = String(count: Int(crew.starCount), repeatedValue: "⭐️")
            if let career = crew.career {
                cell.detailTextLabel?.text = "\(career) \(starString)"
            } else {
                cell.detailTextLabel?.text = starString.isEmpty ? "0 Stars" : starString
            }
        }
    }

}
