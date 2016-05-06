//
//  DectorQRCodeVC.swift
//  二维码
//
//  Created by zhangbin on 16/5/5.
//  Copyright © 2016年 zhangbin. All rights reserved.
//

import UIKit

class DectorQRCodeVC: UIViewController {

    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    
    @IBAction func detectorQRCode() {
        
        // 1. 创建二维码探测器
        
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])
        
        // 2. 探测图片特征
        let image = qrCodeImageView.image
        let imageCI = CIImage(image : image!)
        let result = detector.featuresInImage(imageCI!)
        
        // 3. 遍历特征，打印结果
        var strs = [String]()
        var tempImage = image
        for feature in result{
            
            let qrCodeFeature = feature as! CIQRCodeFeature
            print(qrCodeFeature.messageString)
            strs.append(qrCodeFeature.messageString)
            
            tempImage = drawFrame(tempImage!,feature: qrCodeFeature)
        }
        qrCodeImageView.image = tempImage
        
        // 做个弹窗,弹出结果
        let alertVC = UIAlertController(title: "结果", message: strs.description, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "关闭", style: UIAlertActionStyle.Default){
            (action : UIAlertAction) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertVC.addAction(action)
        presentViewController(alertVC, animated: true, completion: nil)
    }
    func drawFrame(sourceImage: UIImage,feature : CIQRCodeFeature) ->UIImage{
    let size = sourceImage.size
    // 1.开启上下文
    UIGraphicsBeginImageContext(size)
    
    // 2.绘制图片
    sourceImage.drawInRect(CGRectMake(0, 0, size.width, size.height))
     
    // 修改坐标(上下颠倒)
        let context = UIGraphicsGetCurrentContext()
        CGContextScaleCTM(context, 1, -1)
        CGContextTranslateCTM(context, 0, -size.height)
        
    // 3.绘制线宽
        let path = UIBezierPath(rect: feature.bounds)
        UIColor.redColor().setStroke()
        path.lineWidth = 6
        path.stroke()

    // 4.取出合成后的图片
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
    // 5.关闭上下文
        UIGraphicsEndImageContext()

    // 6.返回结果
        return resultImage
    }
    



    
    
}
