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
    // 声明layer对象，这个对象就代表着一个图层，我们可以在这个图形上插入图形
    // 官方解释: AVCaptureVideoPreviewLayer等价CALayer,所以说layer代表着一个图层嘛
    var layer : AVCaptureVideoPreviewLayer?
    
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
                // 将layoutIfNeeded写在动画里面，所以冲击波才有从上到下的动画。
                // 如果将layoutIfNeeded写在外面，冲击波图片是瞬间位移到下面,没有动画效果。
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
        // AVCaptureMetadataOutput的代理是当前控制器。类比UITableView的代理是当前控制器    
        
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        
        // 3. 创建会话，连接输入和输出
        // 精华理解:会话相当于媒婆,这对男女本来不认识，通过这个媒婆，他们才互相认识的。
        
        session = AVCaptureSession()
        if session!.canAddInput(input) && session!.canAddOutput(output){
            session!.addInput(input)// 对象调用对象函数
            session!.addOutput(output) // 对象调用对象函数
        }
        // 3.1 设置扫描识别的类型
         // output.availableMetadataObjectTypes, 识别所有的类型
        // AVMetadataObjectTypeQRCode, 识别二维码
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        // 3.2 添加视频预览图层
        // 精华理解+已验证:layer就是摄像头图层
        layer = AVCaptureVideoPreviewLayer(session: session!)
        // view.bounds就是当前控制器的宽高.让控制器的宽高成为摄像头的宽高
        layer?.frame = view.bounds // 测试验证: layer?.frame = CGRectMake(0, 200, 400, 400)
        
// 如果layer对象插入到了当前控制器的view图层上第0个位置,那么摄像头图层会在冲击波图片+边框图片+和AnimationBackView的后面
// 如果layer对象插入到了当前控制器的view图层上第1个位置,那么摄像头图层会在冲击波图片+边框图片+和AnimationBackView的前面
        
//原理:layer对象就是摄像头图层.当前控制器的view包括4个图层:1.AnimationBackView。2.边框图片。3.冲击波图片。4.摄像头图层
//    插入到当前控制器的view的下标越小，肯定会被下标大的挡住，和入栈原理一样。先加入到view上的对象会被后面的view的对象挡住
        view.layer.insertSublayer(layer!, atIndex: 0)
        // 0插在背景和冲击波图片中间
        // 3.3 设置扫描区域
        // 1. 这个矩形, 是一个比例(0.0 - 1.0)
        // 2. 这个矩形, 是横屏状态下的矩形
        //必须拿到animationBackView的frame，不能拿冲击波的frame，因为冲击波的frame相对于父控件来说是0,0
        // 竖屏旋转时成横屏，原始竖屏的二维码的y坐标的比例就是横屏时的x坐标的比例 (y的比例:二维码的y坐标除以上屏幕的高度)
        // 竖屏旋转时成横屏，原始竖屏的二维码的x坐标的比例就是横屏的y的比例  (x的比例:二维码的x坐标除以屏幕的宽度)
        // 竖屏旋转时成横屏，原始竖屏的二维码的高度的比例就是横屏的宽度的比例(高度的比例:二维码的高度除以屏幕的高度)
        // 竖屏旋转时成横屏，原始竖屏的二维码的宽度的比例就是横屏的高度的比例(高度的比例:二维码的宽度除以屏幕的宽度)
        let size = UIScreen.mainScreen().bounds
        let x : CGFloat = animationBackView.frame.origin.x / size.width
        let y : CGFloat = animationBackView.frame.origin.y / size.height
        let w : CGFloat = animationBackView.frame.size.width / size.width
        let h : CGFloat = animationBackView.frame.size.height / size.height
        // 设置扫描范围为(y,x,h,w)，超出的范围扫描不到。也就是说,只扫描animationBackView这个矩形的范围
        // x和y的比例互换，宽和高的比例互换，
        output.rectOfInterest = CGRectMake(x, y, w, h)

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
            // 如果不移除,当手机不扫描二维码时，之前扫描到的二维码形成的矩形不会从layer上移除,依然会存在屏幕上
            // 执行删除操作,这样每次扫描二维码时,都能保证之前扫描到的被删除了。我们扫描只需要存留一次就行。
            removeQRCodeFrameLayer()
            
             // 遍历扫描到的元数据,放到obj中
            // metadataObjects的存储着坐标范围为[0,1],[0,1]只是表示比例，真实大小不是0-1，我们可以转换成真实的坐标
            // metadataObjects的界限就是一个矩形，这一点必须知道
            for obj in metadataObjects {
                // AVMetadataMachineReadableCodeObject
                if obj.isKindOfClass(AVMetadataMachineReadableCodeObject){
                    // 借助layer来转换四个角的坐标.不转换得到的是0-1的比例
                    let resultObj = layer?.transformedMetadataObjectForMetadataObject(obj as! AVMetadataObject)
                    
                    let codeObj = resultObj as! AVMetadataMachineReadableCodeObject
                   
                    print(codeObj.stringValue)
                   
    //metadataObjects等价obj，obj等价 resultObj，resultObj等价codeObj。范围是个矩形,存储着矩形de 4个点的坐标
                    // 打印4个角的坐标
                     print(codeObj.corners)
                    //将存储着矩形框4个点的坐标的codeObj对象作为参数，放到drawQRCoderFrame函数中,在函数中利用这4个点，描绘成一个实实在在的一个矩形，把这个矩形显示的图层layer上.(layer是自己声明的)
                    drawQRCoderFrame(codeObj)
                }
            
            }
        }
        // 拿到codeObj中存储着的4个点，用这4个点，描绘出一个矩形
func drawQRCoderFrame(codeObj : AVMetadataMachineReadableCodeObject) ->(){
        
        // 绘制边框
        
        // 1.创建形状图层
            
            let shapLayer = CAShapeLayer()
            // 矩形的填充色
            shapLayer.fillColor = UIColor.yellowColor().CGColor
            // 矩形的边框颜色
            shapLayer.strokeColor = UIColor.redColor().CGColor
            // 矩形的线宽
            shapLayer.lineWidth = 6
            
        
        // 2.设置需要显示的图形路径
            // codeObj.corners中存储着4个角的坐标(X,Y)
            let corners = codeObj.corners
        // 2.1 创建一个路径
            let path = UIBezierPath()
         
        var index = 0
            // 遍历矩形框的4个角的点坐标
            for corner in corners{
            // 创建一个(0,0)点.  CGPointZero是一个位于(0,0)的常量
            var point = CGPointZero
        // 遍历出来的4个角的点坐标，每个点坐标都是一个字典(打印得知),所以将字典(Dictionary)转化成点( CGPoint)
                // 第一个参数是字典，第二个参数是点(用地址表示，需要加&)
                // 将转成的点放到point中保存
            CGPointMakeWithDictionaryRepresentation(corner  as! CFDictionary, &point )
                if index == 0 {// 如果index值为0，那么就是矩形框的第一个点
            
            // 先得到矩形框的第一个点。以这个点为起点划线到另一个点,以此类推,最终画成了一个矩形
                path.moveToPoint(point)
                }else{
            // 不是第一个点,就让上一个点为起点(底层自动为我们做,不用纠结)，然后画线到这个点(手动输下面代码)
                path.addLineToPoint(point)
                }
                index += 1
            }
        
            // 闭合路径，否则画出的图形缺个口子
            path.closePath()
            
            shapLayer.path = path.CGPath
            
        // 3.添加到需要显示的图层
        layer?.addSublayer(shapLayer)
        
        }
        
        
func removeQRCodeFrameLayer() ->() {
            // 取出layer图层上的子图层
            guard let subLayers = layer?.sublayers else {return}
            // 遍历自图层
            for subLayer in subLayers {
                // 如果 layer的子图层是CAShapeLayer类型的,就移除。其他的不移除
                // CAShapeLayer就是drawQRCoderFrame函数中的步骤1创建的形状图层
                if subLayer.isKindOfClass(CAShapeLayer){
                    // 只移除layer上的形状图层
                subLayer.removeFromSuperlayer()
                }
            }
            
        }
    }