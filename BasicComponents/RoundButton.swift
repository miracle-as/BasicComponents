//
//  RoundButton.swift
//  Pods
//
//  Created by Morten Olsson on 10/06/16.
//
//

@IBDesignable
class RoundButton: UIButton {

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        layer.cornerRadius = bounds.size.width / 2
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

}
