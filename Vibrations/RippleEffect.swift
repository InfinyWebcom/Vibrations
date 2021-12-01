//
//  RippleEffect.swift
//  Vibrations
//
//  Created by Siddhesh on 1/12/21.
//

import UIKit

enum Directions{
    case up
    case down
    case left
    case right
    case none
}

class RippleEffect: CAReplicatorLayer {
    
    fileprivate var rippleEffect: CAShapeLayer?
    private var animationGroup: CAAnimationGroup?
    
    var rippleColor: UIColor = UIColor.black
    var rippleRepeatCount: CGFloat = 1.0
    var rippleWidth: CGFloat = 2
    
    var rippleRadius: CGFloat!
    var delay: CFTimeInterval!
    var animationDuration: CFTimeInterval!
    var isTap: Bool!
    var startAngle:CGFloat = .pi
    var endAngle:CGFloat = 0
    var direction: Directions = .none
    
    required init(delay: Double, animationDuration: Double, rippleRadius: CGFloat = 50, instanceCount: Int = 3, isTap: Bool,direction: Directions) {
        super.init()
        self.delay = delay
        self.animationDuration = animationDuration
        self.rippleRadius = rippleRadius
        self.instanceCount = instanceCount
        self.isTap = isTap
        self.direction = direction
        
        setupRippleEffect()
        
        repeatCount = Float(rippleRepeatCount)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        //var path = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: rippleRadius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        var path = UIBezierPath()
        //        path.move(to: CGPoint(x: -50, y: -50))
        //        path.addQuadCurve(to: CGPoint(x: 50, y: -50), controlPoint: CGPoint(x: 0, y: 0))
        //
        path.move(to: CGPoint(x: -rippleRadius, y: -rippleRadius))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rippleRadius, y: rippleRadius))
        
        if isTap{
            path = UIBezierPath(roundedRect: CGRect(x: -rippleRadius, y: -rippleRadius, width: rippleRadius*2, height: rippleRadius*2), cornerRadius: rippleRadius)
        }
        rippleEffect?.path = path.cgPath
        
        instanceCount = 2
        instanceDelay = delay ?? 0.05
    }
    
    func setupRippleEffect() {
        rippleEffect = CAShapeLayer()
        rippleEffect?.fillColor = UIColor.clear.cgColor
        rippleEffect?.strokeColor = UIColor.black.cgColor
        rippleEffect?.lineWidth = CGFloat(rippleWidth)
        rippleEffect?.opacity = 0
        
        switch direction {
        case .up:
            startAngle = 0
            endAngle = .pi
        case .down:
            startAngle = .pi
            endAngle = 0
        case .left:
            break
        case .right:
            break
        case .none:
            break
        }
        
        addSublayer(rippleEffect!)
    }
    
    func startAnimation() {
        setupAnimationGroup()
        rippleEffect?.add(animationGroup!, forKey: "ripple")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.rippleEffect?.removeAnimation(forKey: "ripple")
        }
        
    }
    
    func stopAnimation() {
        rippleEffect?.removeAnimation(forKey: "ripple")
    }
    
    func setupAnimationGroup() {
        
        let group = CAAnimationGroup()
        group.duration = animationDuration
        group.repeatCount = self.repeatCount
        group.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.fromValue = 0.1;
        scaleAnimation.toValue = 1.0;
        scaleAnimation.duration = animationDuration
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.duration = animationDuration
        let fromAlpha = 1.0
        opacityAnimation.values = [fromAlpha, (fromAlpha * 0.5), 0];
        opacityAnimation.keyTimes = [0, 0.2, 1];
        
        group.animations = [scaleAnimation, opacityAnimation]
        
        animationGroup = group;
        animationGroup!.delegate = self;
    }
}

extension RippleEffect: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let count = rippleEffect?.animationKeys()?.count , count > 0 {
            rippleEffect?.removeAllAnimations()
        }
    }
}
