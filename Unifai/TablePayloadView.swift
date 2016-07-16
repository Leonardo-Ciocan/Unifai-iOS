//
//  TablePayloadView.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 29/04/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit
import SnapKit

class TablePayloadView: UIView {

    override func drawRect(rect: CGRect) {
        self.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.02).CGColor
        self.layer.borderColor = UIColor.greenColor().CGColor
        self.layer.borderWidth = 0
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
    
    
    var payload : TablePayload?
    
    func loadData(payload : TablePayload){
        self.backgroundColor = currentTheme.shadeColor
        self.payload = payload
        
//        self.snp_makeConstraints(closure: {
//            (make) -> Void in
//            //make.height.equalTo(50 * CGFloat(rows.count))
//            make.leading.trailing.equalTo(0)
//            make.height.equalTo(CGFloat(rows.count + 1) * 50.0)
//            make.top.equalTo(self.superview!)
//        })
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        guard payload != nil else {return}
        
        self.subviews.forEach({ $0.removeFromSuperview()})
        
        let cols = payload!.columns;
        let rows = payload!.rows;
        
        self.hidden = true
        let colWidth = Int(self.superview!.frame.width / CGFloat(cols.count))
        for col in 0..<cols.count{
            print(col)
            let colLabel = UILabel()
            colLabel.textColor = currentTheme.foregroundColor
            colLabel.textAlignment = .Center
            colLabel.font = colLabel.font.fontWithSize(13)
            colLabel.text = payload!.columns[col]
            colLabel.backgroundColor = currentTheme.shadeColor
            self.addSubview(colLabel)
                        colLabel.snp_makeConstraints(closure: { (make)->Void in
                            make.leading.equalTo(colWidth * col)
                            make.width.equalTo(colWidth)
                            make.top.equalTo(0)
                            make.height.equalTo(50)
                        })
            
            
            for row in 0..<rows.count{
                let label = UILabel()
                label.textColor = currentTheme.foregroundColor
                label.textAlignment = .Center
                label.font = label.font.fontWithSize(12)
                label.text = payload!.rows[row][col]
                self.addSubview(label)
                
                                label.snp_makeConstraints(closure: { (make)->Void in
                                    make.leading.equalTo(colWidth * col)
                                    make.width.equalTo(colWidth)
                                    make.top.equalTo(50 * row + 50)
                                    make.height.equalTo(50)
                                })
            }
        }
        self.hidden = false
    }
    
}
