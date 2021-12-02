//
//  ViewController.swift
//  Vibrations
//
//  Created by Siddhesh on 30/11/21.
//

import UIKit
import CoreHaptics

class ViewController: UIViewController, CAAnimationDelegate {
    
    // MARK: - @IBOutlet
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var pauseResumeBtn: UIButton!
    @IBOutlet weak var infoResetLbl: UILabel!
    @IBOutlet weak var minusBtn: UIButton!
    @IBOutlet weak var plusBtn: UIButton!
    
    // MARK: - class Properties
    private var hapticEngine: CHHapticEngine?
    private var eventSet = [CHHapticEvent]()
    private var touchEvents: [UIEvent]?
    private var intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
    private var sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
    private var controlValue:Float = 1
    
    private var count:Double = 0
    private var timercount:Double = 15
    private var pressedCount:TimeInterval = 0
    private var relativeTime:TimeInterval = 0
    private var timer = Timer()
    private var secondsTimer = Timer()
    private var touchBegin = false
    private var startRecording = false
    
    var rippleEffect: RippleEffect?
    var direction: Directions = .none
    
    var playTime: Double = 0
    
    private var continuousPlayer: CHHapticAdvancedPatternPlayer!
    
    // MARK: - ViewController Events
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordBtn.layer.cornerRadius = recordBtn.frame.size.height/2
        recordBtn.setImage(UIImage(named: "record"), for: .normal)
        
        setupHaptic()
        setupGesture()
        
        self.minusBtn.isHidden = true
        self.plusBtn.isHidden = true
    }
    
    // MARK: - touch Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        controlValue = AppUtils.getDynamicValue(touch: touch, view: self.view)
        if startRecording{
            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
            
            touchBegin = true
            relativeTime = count
            
            let touch = touches.first!
            let location = touch.location(in: self.view)
            
            controlValue = AppUtils.getDynamicValue(touch: touch, view: self.view)
            intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: controlValue)
            sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: controlValue)
            
            // for recording
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity,sharpness], relativeTime: relativeTime,duration: 0.1)
            
            // for instance playing
            let currentEvent = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity,sharpness], relativeTime: 0,duration: 0.1)
            
            eventSet.append(event)
            
            // MARK: Ripple Effect
            rippleEffect = RippleEffect(delay: 0.3, animationDuration: 0.8, rippleRadius: 50, instanceCount: 2,isTap: true, direction: direction)
            
            if let rippleLayer = rippleEffect {
                rippleLayer.position = location
                self.view.layer.addSublayer(rippleLayer)
                rippleLayer.startAnimation()
            }
            
            do {
                try self.hapticEngine?.start()
                let pattern = try CHHapticPattern(events: [currentEvent], parameters: [])
                let player = try hapticEngine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)
            } catch {
                print("Failed to play pattern: \(error.localizedDescription).")
            }
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if startRecording{
            // MARK: Ripple Effect
            let touch = touches.first!
            let location = touch.location(in: self.view)
            let previousLocation = touch.previousLocation(in: self.view)
            
            controlValue = AppUtils.getDynamicValue(touch: touch, view: self.view)
            intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: controlValue)
            sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: controlValue)
            relativeTime = count
            // for recording
            print("relativeTime",relativeTime,"controlValue",controlValue)
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity,sharpness], relativeTime: relativeTime,duration: 0.1)
            
            // for instance playing
            let currentEvent = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity,sharpness], relativeTime: 0,duration: 0.1)
            //            let currentEvent = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity,sharpness], relativeTime: relativeTime,duration: 0.1)
            eventSet.append(event)
            
            do {
                try self.hapticEngine?.start()
                let pattern = try CHHapticPattern(events: [currentEvent], parameters: [])
                let player = try hapticEngine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)
            } catch {
                print("Failed to play pattern: \(error.localizedDescription).")
            }
            
            /*
             direction = .none
             
             if (location.x - previousLocation.x > 0) {
             direction = .right
             } else {
             direction = .left
             }
             
             if (location.y - previousLocation.y > 0) {
             direction = .down
             } else {
             direction = .up
             }
             */
            
            rippleEffect = RippleEffect(delay: 0.2, animationDuration: 1, rippleRadius: 70, instanceCount: 3,isTap: false, direction: direction)
            if let rippleLayer = rippleEffect {
                rippleLayer.position = location
                self.view.layer.addSublayer(rippleLayer)
                rippleLayer.startAnimation()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if startRecording{
            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
            touchBegin = false
            var duration = pressedCount
            if duration == 0 {
                duration = 0.01
            }
            
            pressedCount = 0
            
            stopHapticEngine()
            
            playTime = relativeTime + duration
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity,sharpness], relativeTime: relativeTime,duration: duration)
            //eventSet.append(event)
        }
    }
    
    
    // MARK: @objc func
    @objc func startTimer() {
        count += 0.1
        if touchBegin{
            pressedCount += 0.1
        }
    }
    
    @objc func startSecondsTimer() {
        timercount -= 1
        if timercount < 10{
            recordBtn.setTitle("00:0\(Int(timercount))", for: .normal)
        }else{
            recordBtn.setTitle("00:\(Int(timercount))", for: .normal)
        }
        
        if timercount == 0{
            let fakeTouch:Set<UITouch> = [UITouch()]
            let event = UIEvent()
            touchesEnded(fakeTouch, with: event)
            
            stopHapticEngine()
            
            startRecording = false
            
            timer.invalidate()
            secondsTimer.invalidate()
            
            count = 0
            pressedCount = 0
            relativeTime = 0
            timercount = 15
            
            recordBtn.setImage(UIImage(named: "play"), for: .normal)
            recordBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
            recordBtn.backgroundColor = UIColor(named: "kinGreen")
            recordBtn.setTitle("", for: .normal)
            infoResetLbl.text = "Reset"
            infoResetLbl.textColor = .systemBlue
        }
    }
    
    // MARK: - Haptic setup
    func setupHaptic(){
        do {
            hapticEngine = try CHHapticEngine()
        } catch let error {
            print("Haptic engine Creation Error: \(error)")
        }
        
        hapticEngine?.stoppedHandler = { reason in
            print("Haptic Engine stopped: \(reason)")
        }
    }
    
    func stopHapticEngine(){
        hapticEngine?.stop(completionHandler: { error in
            if let error = error{
                print("hapticEngine?.stop(completionHandler error",error)
            }
        })
    }
    
    // MARK: - UITapGestureRecognizer
    func setupGesture(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTap(withGestureRecognizer:)))
        infoResetLbl.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        if infoResetLbl.text?.lowercased() == "reset".lowercased(){
            
            stopHapticEngine()
            
            pauseResumeBtn.tag = 12
            self.minusBtn.isHidden = true
            self.plusBtn.isHidden = true
            recordBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            recordBtn.setImage(UIImage(named: "record"), for: .normal)
            recordBtn.backgroundColor = UIColor(named: "kinRed")
            infoResetLbl.textColor = .black
            infoResetLbl.text = "Click on record button to begin"
            eventSet = []
            
        }
    }
    
    // MARK: @IBAction UIButton
    
    @IBAction func recordPattern(_ sender: UIButton) {
        if sender.currentImage == UIImage(named: "record"){
            startRecording = true
            timer = Timer.scheduledTimer(timeInterval: 0.1 ,target: self, selector: #selector(startTimer), userInfo: nil, repeats: true)
            
            secondsTimer = Timer.scheduledTimer(timeInterval: 1 ,target: self, selector: #selector(startSecondsTimer), userInfo: nil, repeats: true)
            recordBtn.setTitle("00:\(Int(timercount))", for: .normal)
            recordBtn.backgroundColor = UIColor(named: "kinOrange")
            recordBtn.setImage(UIImage(), for: .normal)
            infoResetLbl.text = "Touch on the screen to record vibrations"
        }else if sender.currentImage == UIImage(named: "play"){
            controlValue = 1.0
            self.minusBtn.isHidden = false
            self.plusBtn.isHidden = false
            recordBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            recordBtn.backgroundColor = UIColor(named: "kinBlue")
            recordBtn.setImage(UIImage(named: "playing"), for: .normal)
            do {
                /*
                 try self.hapticEngine?.start()
                 let pattern = try CHHapticPattern(events: eventSet, parameters: [])
                 let player = try hapticEngine?.makePlayer(with: pattern)
                 try player?.start(atTime: 0)
                 
                 DispatchQueue.main.asyncAfter(deadline: .now() + (self.playTime + 1)) {
                 self.recordBtn.setImage(UIImage(named: "play"), for: .normal)
                 self.recordBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
                 self.recordBtn.backgroundColor = UIColor(named: "kinGreen")
                 self.recordBtn.setTitle("", for: .normal)
                 }
                 */
                
                try self.hapticEngine?.start()
                
                let pattern = try CHHapticPattern(events: eventSet, parameters: [])
                
                continuousPlayer = try hapticEngine?.makeAdvancedPlayer(with: pattern)
                continuousPlayer.loopEnabled = true
                continuousPlayer.loopEnd = 18//(self.playTime + 3)
                try continuousPlayer.start(atTime: 0)
                
                continuousPlayer.completionHandler = { _ in
                    DispatchQueue.main.async {
                        print("ended")
                    }
                }
                
            } catch {
                print("Failed to play pattern: \(error.localizedDescription).")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.recordBtn.setImage(UIImage(named: "play"), for: .normal)
                    self.recordBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
                    self.recordBtn.backgroundColor = UIColor(named: "kinGreen")
                    self.recordBtn.setTitle("", for: .normal)
                }
            }
            
        }else if sender.currentImage == UIImage(named: "playing"){
            do{
                try continuousPlayer.stop(atTime: 0.30)
                
                self.recordBtn.setImage(UIImage(named: "play"), for: .normal)
                self.recordBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
                self.recordBtn.backgroundColor = UIColor(named: "kinGreen")
                self.recordBtn.setTitle("", for: .normal)
                print("stopped")
                stopHapticEngine()
            }catch{
                print("Failed to stop pattern: \(error.localizedDescription).")
            }
        }
    }
    
    @IBAction func pauseOrResumeAction(_ sender: UIButton) {
        if sender.tag == 12{
            pauseResumeBtn.tag = 11
            do {
                try continuousPlayer.pause(atTime: 1)
            }catch{
                print("Failed to pasue pattern: \(error.localizedDescription).")
            }
        }else{
            pauseResumeBtn.tag = 12
            do {
                try continuousPlayer.resume(atTime: 1)
            }catch{
                print("Failed to resume pattern: \(error.localizedDescription).")
            }
        }
    }
    
    @IBAction func increaseIntensity(_ sender: UIButton) {
        do {
            if controlValue < 1.0 {
                self.controlValue += 0.2
            }
            let intensity = CHHapticDynamicParameter(parameterID: .hapticIntensityControl, value: self.controlValue, relativeTime: 0.5)
            let sharpness = CHHapticDynamicParameter(parameterID: .hapticSharpnessControl, value: self.controlValue, relativeTime: 0.5)
            try continuousPlayer.sendParameters([intensity,sharpness], atTime: 0.1)
        }catch{
            print("Failed to increase Intensity of pattern: \(error.localizedDescription).")
        }
    }
    
    @IBAction func decreaseIntensity(_ sender: UIButton) {
        do {
            if controlValue > 0 {
                self.controlValue -= 0.2
            }
            let intensity = CHHapticDynamicParameter(parameterID: .hapticIntensityControl, value: self.controlValue, relativeTime: 0.5)
            let sharpness = CHHapticDynamicParameter(parameterID: .hapticSharpnessControl, value: self.controlValue, relativeTime: 0.5)
            try continuousPlayer.sendParameters([intensity,sharpness], atTime: 0.1)
        }catch{
            print("Failed to decrease Intensity of pattern: \(error.localizedDescription).")
        }
    }
}



