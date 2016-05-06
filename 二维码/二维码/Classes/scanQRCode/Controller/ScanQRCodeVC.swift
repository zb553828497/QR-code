//
//  ScanQRCodeVC.swift
//  二维码
//
//  Created by zhangbin on 16/5/5.
//  Copyright © 2016年 zhangbin. All rights reserved.
//

import UIKit
import AVFoundation
class ScanQRCodeVC : UIViewController {

    @IBOutlet weak var animationBackView: UIView!

    @IBOutlet weak var toBottom: NSLayoutConstraint!
    @IBOutlet weak var chongjiboImageView: UIImageView!
    
    var session : AVCaptureSession?
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        startAnimation()
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
     //stopAnimation()
    startScan()
        
        
    }
    
    func startAnimation()->(){
        // 先移动动画到顶部
        toBottom.constant = animationBackView.frame.size.height
        // 作用:及时更新上面设置的约束，从而让冲击波图片及时的移动到250的位置
        view.layoutIfNeeded()
        
        // 再移动动画到底部
        toBottom.constant = -animationBackView.frame.size.height
            // 每隔2秒循环执行动画
            UIView.animateWithDuration(2){
            // 不断执行动画
            UIView.setAnimationRepeatCount(MAXFLOAT)
                self.view.layoutIfNeeded()
            }
        
        }
    
    func startScan() ->(){
        
        // 1.获取摄像头设备
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        // 1.1 设置为输入设备
        var input :AVCaptureDeviceInput?
        do{
        input = try AVCaptureDeviceInput(device: device)
        }catch{
            print(error)
            return
        }
        // 2.创建元数据输出处理对象
        let output = AVCaptureMetadataOutput()
        // 2.1 设置元数据输出处理的代理, 来接收输出的数据内容
        // 当前ScanQRCodeVC控制器作为元数据输出处理的代理。
        // AVCaptureMetadataOutput的代理是当前控制器。类比UITableView的代理是当前控制器        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        
        // 3. 创建会话，连接输入和输出
        
        session = AVCaptureSession()
        if session!.canAddInput(input) && session!.canAddOutput(output){
            session!.addInput(input)
            session!.addOutput(output)
        }
        // 3.1 设置扫描识别的类型
         // output.availableMetadataObjectTypes, 识别所有的类型
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        // 3.2 添加视频预览图层
        let layer = AVCaptureVideoPreviewLayer(session: session!)
        layer.frame = view.bounds
        // 如果layer对象插入到了view图层上第0个位置，那么冲击波和四角方框会在摄像头界面的前面
        // 如果layer对象插入到了view图层上第1个位置,那么摄像头界面会挡住冲击波和四角方框
        view.layer.insertSublayer(layer, atIndex: 0)
        
        // 4.启动会话，开始扫描
        session!.startRunning()
    }

    // 停止动画
    func stopAnimation() -> (){
         // 动画的本质就是作用在layer层, 所以, 只需要拿到对应的动画layer, 移除就可以
        chongjiboImageView.layer.removeAllAnimations()
    }
}
// 遵守代理协议
    extension ScanQRCodeVC : AVCaptureMetadataOutputObjectsDelegate{
        // 实现代理方法
        // 既然遵守了协议，所以是系统底层自动为我们调用,所以不用考虑如何调用的。
        //系统什么时候调用这个代理方法呢?只要摄像头扫描到结果之后,就调用.最后一次也会调用
        // 代理输出 扫描到的二维码数据
     
        func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
             // 遍历扫描到的元数据放到obj中
            for obj in metadataObjects {
            
                if obj.isKindOfClass(AVMetadataMachineReadableCodeObject){
                    let codeObj = obj as! AVMetadataMachineReadableCodeObject
                    print(codeObj.stringValue)
                
                }
            
            }
        }

    }