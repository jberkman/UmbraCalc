//
//  SelectionTableViewController.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-29.
//  Copyright © 2015 jacob berkman.
//
//  Based on and includes portions of Moduler Kolonization System by RoverDude
//  https://github.com/BobPalmer/MKS/
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial
//  4.0 International License. To view a copy of this license, visit
//  http://creativecommons.org/licenses/by-nc/4.0/.
//

import UIKit

class SelectionTableViewController: UITableViewController {

    weak var delegate: ViewControllerDelegate?

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        guard navigationController?.viewControllers.contains(self) != true else { return }
        delegate?.viewControllerDidFinish(self)
    }

}
