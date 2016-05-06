//
//  GeneratorQRCodeVC.swift
//  二维码
//
//  Created by zhangbin on 16/5/5.
//  Copyright © 2016年 zhangbin. All rights reserved.
//

import UIKit
import CoreImage
class GeneratorQRCodeVC: UIViewController {


    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    @IBOutlet weak var inputTV: UITextView!
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        view.endEditing(true)
        
        // 生成二维码
        
        // 1.创建一个二维码滤镜
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        // 1.1 默认恢复设置
        filter?.setDefaults()
        
        // 2.设置输入的内容
        // 通过kvc设置一个属性，value必须是NSData类型的数据
        let inputStr = inputTV.text
        let data = inputStr.dataUsingEncoding(NSUTF8StringEncoding)
        filter?.setValue(data, forKey: "inputMessage")
        
        // 2.1 设置滤镜的纠错率
        filter?.setValue("M", forKey: "inputCorrectionLevel")
        
        // 3. 取出生成的图片
        var outImage = filter?.outputImage
        let transform = CGAffineTransformMakeScale(20, 20)
        outImage = outImage?.imageByApplyingTransform(transform)
        
        // 4.展示(原始图片大小 23.0， 23.0),放大20倍
        var imageUI = UIImage(CIImage: outImage!)
        
        // 5. 添加一个自定义图片
        let centerImage = UIImage(named: "erha.png")
        imageUI = createImage(imageUI, centerImage: centerImage!)
        
        print(imageUI.size)
        
        // 必不可少，赋值给控件的image属性
        qrCodeImageView.image = imageUI
       

    }
    func createImage(sourceImage : UIImage,centerImage:UIImage) -> UIImage{
        
        let size = sourceImage.size
    
        
        // 1.开启上下文
        UIGraphicsBeginImageContext(size)
        
        // 2.绘制大图片
        sourceImage.drawInRect(CGRectMake(0, 0, size.width, size.height))
        
        // 3. 绘制小图片
        
        let w : CGFloat = 80
        let h : CGFloat = 80
        let x : CGFloat = (size.width - w) * 0.5
        let y : CGFloat = (size.height - h) * 0.5
        
        centerImage.drawInRect(CGRectMake(x,y, w, h))
        
        // 4.取出结果图片
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // 5.关闭上下文
        UIGraphicsEndImageContext()
        
        // 6.返回结果
        return resultImage
        }
        
    }

