//
//  ScrollViewExtension.swift
//  GlueTeam
//
//  Created by LIEMNH on 12/10/2023.
//

import UIKit

extension UIScrollView {
    func setScrollToBottom(animated: Bool = true){
        if self.contentSize.height < self.bounds.height {return}
        let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.height)
        self.setContentOffset(bottomOffset, animated: animated)
    }

    var verticalOffsetForTop: CGFloat{
        return -contentInset.top
    }
    
    var verticalOffsetForBottom: CGFloat{
        return contentSize.height + contentInset.bottom - bounds.height
    }

    var horizontalOffsetForRight: CGFloat{
        return contentSize.width + contentInset.right - bounds.width
    }
    
    var isAtTopCenter: Bool{
        return contentOffset.y == verticalOffsetForTop
    }
    
    var isAtTop: Bool{
        return contentOffset.y <= verticalOffsetForTop
    }
    
    var isAtBottom: Bool{
        return contentOffset.y >= verticalOffsetForBottom
    }
    
    var isRight: Bool{
        return contentOffset.x == horizontalOffsetForRight
    }
}
