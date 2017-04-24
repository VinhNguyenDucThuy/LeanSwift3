//
//  ViewController.swift
//  DrawLine
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 4/19/17.
//  Copyright © 2017 TruePlus. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    @IBOutlet weak var colorDraw: UIView!
    
    @IBOutlet weak var drawArea: UIView!
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    var lastPoint: CGPoint?
    var secondPoint: CGPoint?
    var swiped = false
    var redValue = 0.0
    var greenValue = 0.0
    var blueValue = 0.0
    var drawColor : UIColor?
    var layers = [UIView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: nil)
        view.addGestureRecognizer(tapGestureRecognizer)
        
        redSlider.addTarget(self, action: #selector(baseColorChangerValue), for: UIControlEvents.valueChanged)
        greenSlider.addTarget(self, action: #selector(baseColorChangerValue), for: UIControlEvents.valueChanged)
        blueSlider.addTarget(self, action: #selector(baseColorChangerValue), for: UIControlEvents.valueChanged)
        redValue = Double(redSlider.value)
        greenValue = Double(greenSlider.value)
        blueValue = Double(blueSlider.value)
        self.changeColorDraw()
    }

    func changeColorDraw (){
        drawColor = UIColor.init(colorLiteralRed: (Float(redValue/255)), green: (Float(greenValue/255)), blue: (Float(blueValue/255)), alpha: 1)
        colorDraw.backgroundColor = drawColor
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        if let touch = touches.first as UITouch? {
            lastPoint = (touch.location(in: drawArea))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if let touch = touches.first as UITouch? {
            let currentPoint = touch.location(in: drawArea)
            drawLineFrom(fromPoint: lastPoint!, toPoint: currentPoint)
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let archive = NSKeyedArchiver.archivedData(withRootObject: drawArea)
        let cloneUIView = NSKeyedUnarchiver.unarchiveObject(with: archive) as! UIView
        
        drawArea.layer.sublayers?.forEach {
            let archiveLayer = NSKeyedArchiver.archivedData(withRootObject: $0)
            let cloneLayer = NSKeyedUnarchiver.unarchiveObject(with: archiveLayer) as! CAShapeLayer
            cloneUIView.layer.addSublayer(cloneLayer)
            $0.removeFromSuperlayer()
        }

        layers.append(cloneUIView)
        self.view.addSubview(cloneUIView)
        self.view.bringSubview(toFront: drawArea)
    }

    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint){
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: fromPoint)
        linePath.addLine(to: toPoint)
        line.path = linePath.cgPath
        line.strokeColor = drawColor?.cgColor
        line.lineWidth = 1
        line.lineJoin = kCALineJoinRound
        drawArea.layer.addSublayer(line)
    }
    
    func baseColorChangerValue(_ sender: UISlider) {
        if redSlider == sender {
            redValue = Double(redSlider.value)
        } else if greenSlider == sender {
            greenValue = Double(greenSlider.value)
        } else if blueSlider == sender{
            blueValue = Double(blueSlider.value)
        }
        self.changeColorDraw()
    }
    
    @IBAction func backDraw(_ sender: Any) {
        if layers.count > 0 {
            let lineView = layers.last;
            lineView?.removeFromSuperview();
            layers.removeLast()
        }
    }
    
    @IBAction func deleteDraw(_ sender: Any) {
        for drawLayer in layers {
            drawLayer.removeFromSuperview()
        }
    }
    @IBAction func savePicture(_ sender: Any) {
        let pictureView = UIView()
        pictureView.frame = drawArea.frame
        
        for drawLayer in layers {
            drawLayer.layer.sublayers?.forEach {
                let archiveLayer = NSKeyedArchiver.archivedData(withRootObject: $0)
                let cloneLayer = NSKeyedUnarchiver.unarchiveObject(with: archiveLayer) as! CAShapeLayer
                pictureView.layer.addSublayer(cloneLayer)
            }
        }
        
        let picture = self.takeSnapshotOfView(view: pictureView)
        UIImageWriteToSavedPhotosAlbum(picture!, nil, nil, nil);
    }
    
    func takeSnapshotOfView(view:UIView) -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: view.frame.size.width, height: view.frame.size.height))
        view.drawHierarchy(in: CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height), afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

