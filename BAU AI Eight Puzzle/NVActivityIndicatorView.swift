//
//  NVActivityIndicatorView.swift
//  NVActivityIndicatorViewDemo
//
//  Created by Nguyen Vinh on 7/21/15.
//  Copyright (c) 2015 Nguyen Vinh. All rights reserved.
//

import UIKit

public enum NVActivityIndicatorType {
    case blank
    case ballPulse
    case ballGridPulse
    case ballClipRotate
    case squareSpin
    case ballClipRotatePulse
    case ballClipRotateMultiple
    case ballPulseRise
    case ballRotate
    case cubeTransition
    case ballZigZag
    case ballZigZagDeflect
    case ballTrianglePath
    case ballScale
    case lineScale
    case lineScaleParty
    case ballScaleMultiple
    case ballPulseSync
    case ballBeat
    case lineScalePulseOut
    case lineScalePulseOutRapid
    case ballScaleRipple
    case ballScaleRippleMultiple
    case ballSpinFadeLoader
    case lineSpinFadeLoader
    case triangleSkewSpin
    case pacman
    case ballGridBeat
    case semiCircleSpin
}

open class NVActivityIndicatorView: UIView {
    fileprivate let DEFAULT_TYPE: NVActivityIndicatorType = .pacman
    fileprivate let DEFAULT_COLOR = UIColor.white
    fileprivate let DEFAULT_SIZE: CGSize = CGSize(width: 40, height: 40)
    
    fileprivate var type: NVActivityIndicatorType
    fileprivate var color: UIColor
    fileprivate var size: CGSize
    
    var animating: Bool = false
    var hidesWhenStopped: Bool = true
    
    /**
        Create a activity indicator view with default type, color and size
        This is used by storyboard to initiate the view
    
        - Default type is pacman\n
        - Default color is white\n
        - Default size is 40
    
        :param: decoder
    
        :returns: The activity indicator view
    */
    required public init(coder aDecoder: NSCoder) {
        self.type = DEFAULT_TYPE
        self.color = DEFAULT_COLOR
        self.size = DEFAULT_SIZE
        super.init(coder: aDecoder)!;
    }
    
    /**
        Create a activity indicator view with specified type, color, size and size
        
        :param: frame view's frame
        :param: type animation type, value of NVActivityIndicatorType enum
        :param: color color of activity indicator view
        :param: size actual size of animation in view
    
        :returns: The activity indicator view
    */
    public init(frame: CGRect, type: NVActivityIndicatorType, color: UIColor?, size: CGSize?) {
        self.type = type
        self.color = DEFAULT_COLOR
        self.size = DEFAULT_SIZE
        super.init(frame: frame)
        
        if let _color = color {
            self.color = _color
        }
        if let _size = size {
            self.size = _size
        }
    }
    
    /**
        Create a activity indicator view with specified type, color and default size
    
        - Default size is 40
        
        :param: frame view's frame
        :param: value animation type, value of NVActivityIndicatorType enum
        :param: color color of activity indicator view
    
        :returns: The activity indicator view
    */
    convenience public init(frame: CGRect, type: NVActivityIndicatorType, color: UIColor?) {
        self.init(frame: frame, type: type, color: color, size: nil)
    }
    
    /**
        Create a activity indicator view with specified type and default color, size
    
        - Default color is white
        - Default size is 40
    
        :param: view view's frame
        :param: value animation type, value of NVActivityIndicatorType enum
    
        :returns: The activity indicator view
    */
    convenience public init(frame: CGRect, type: NVActivityIndicatorType) {
        self.init(frame: frame, type: type, color: nil)
    }
    
    /**
        Start animation
    */
    open func startAnimation() {
        if hidesWhenStopped && isHidden {
            isHidden = false
        }
        if (self.layer.sublayers == nil) {
            setUpAnimation()
        }
        self.layer.speed = 1
        self.animating = true
    }
    
    /**
        Stop animation
    */
    open func stopAnimation() {
        self.layer.speed = 0
        self.animating = false
        if hidesWhenStopped && !isHidden {
            isHidden = true
        }
    }
    
    // MARK: Privates
    
    fileprivate func setUpAnimation() {
        let animation: NVActivityIndicatorAnimationDelegate = animationOfType(self.type)
        
        self.layer.sublayers = nil
        animation.setUpAnimationInLayer(self.layer, size: self.size, color: self.color)
    }
    
    fileprivate func animationOfType(_ type: NVActivityIndicatorType) -> NVActivityIndicatorAnimationDelegate {
        switch type {
        case .blank:
            return NVActivityIndicatorAnimationBallRotate()
        case .ballRotate:
            return NVActivityIndicatorAnimationBallRotate()
        default:
            return NVActivityIndicatorAnimationBallRotate()
        }
    }
}
