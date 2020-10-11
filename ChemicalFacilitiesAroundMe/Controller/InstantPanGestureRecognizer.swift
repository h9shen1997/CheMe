//
//  InstantPanGestureRecognizer.swift
//  ChemicalFacilitiesAroundMe
//
//  Created by Haotian Shen on 10/4/20.
//

import UIKit

class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == UIGestureRecognizer.State.began {
            return
        }
        super.touchesBegan(touches, with: event)
        self.state = UIGestureRecognizer.State.began
    }
}
