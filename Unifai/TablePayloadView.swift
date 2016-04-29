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
        self.layer.backgroundColor = UIColor.lightGrayColor().CGColor
        self.layer.borderColor = UIColor.greenColor().CGColor
        self.layer.borderWidth = 0
       
    }
    
    
    
    func loadData(payload : TablePayload){
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)

        
        let cols = payload.columns;
        let rows = payload.rows;
        
        self.snp_makeConstraints(closure: {
            (make) -> Void in
            //make.height.equalTo(50 * CGFloat(rows.count))
            make.leading.trailing.equalTo(0)
            make.top.equalTo(self.superview!).offset(0)
            make.bottom.equalTo(self.superview!).offset(0)
        })
        
        self.frame = CGRect(x: 0.0,
                            y: 0.0,
                            width: 555,
                            height: CGFloat(rows.count + 1) * 50.0)
        
        let colWidth = self.frame.width / CGFloat(cols.count)
        
        for col in 0..<cols.count{
            for row in 0..<rows.count{
                let label = UILabel()
                label.text = payload.rows[row][col]
                self.addSubview(label)

                label.snp_makeConstraints(closure: { (make)->Void in
                    make.leading.equalTo(self.superview!).multipliedBy(1/cols.count * col)
                    make.trailing.equalTo(self.superview!).multipliedBy(1/cols.count - col)
                    make.top.equalTo(self.superview!).multipliedBy(1/rows.count * row)
                })
            }
        }
        
        
    }
    
}
