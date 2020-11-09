//
//  ViewController.swift
//  Tracks
//
//  Created by 周登杰 on 2020/11/6.
//

import UIKit



struct Dot {
    var originX: CGFloat
    var originY: CGFloat
    var pressure: CGFloat
}

enum Track:Equatable {
    
    case MoveTo(dot: Dot)//笔画的起点
    case AddTo(dot: Dot)//绘画的点
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        switch (lhs, rhs) {
        case (.MoveTo(let ld), .MoveTo(let rd)):
            return ld.originX == rd.originX && ld.originY == rd.originY && ld.pressure == rd.pressure
        case (.AddTo(let ld), .AddTo(let rd)):
            return ld.originX == rd.originX && ld.originY == rd.originY && ld.pressure == rd.pressure
        case (.MoveTo(let ld), .AddTo(let rd)):
            return ld.originX == rd.originX && ld.originY == rd.originY && ld.pressure == rd.pressure
        case (.AddTo(let ld), .MoveTo(let rd)):
            return ld.originX == rd.originX && ld.originY == rd.originY && ld.pressure == rd.pressure
        }
    }
}



class ViewController: UIViewController {
    
    var lineView: QuartzLineView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let scroll = UIScrollView(frame: self.view.bounds)
        scroll.minimumZoomScale = 1.0
        scroll.maximumZoomScale = 3.0
        scroll.delegate = self
    
        view.addSubview(scroll)
        
        let lineView =  QuartzLineView(frame: CGRect(x: 0, y: 0, width:UIScreen.main.bounds.width, height:UIScreen.main.bounds.height))
        lineView.backgroundColor = UIColor.white
        scroll.addSubview(lineView)
        self.lineView = lineView
        
        
        
        
        DispatchQueue.global().async {
            let dots:[[Track]] = self.standardizeCoordinateData()
            DispatchQueue.main.async {

                var count = 0
                var oldDots: [Track] = []

                Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { (timer) in
                    if count < dots.count {
                        oldDots = oldDots + dots[count]
                        //通过降低重绘频率，减少cpu占用，维持着15%以下；内存占用维持在21M左右
                        lineView.dots = oldDots

//                        if count % 2 == 0 {
//                        }
                        count += 1

                    } else {
                        //达到无限绘制，测试性能参数
//                        count = 0
//                        oldDots = []
//                        print("drawing: \(count)")
                    }
                }
            }
        }
    }
    
    
    //MARK: ---以下每一行数据代表一个笔画，每个笔画由N个点组成，每个点包含（X坐标、Y坐标、压力值），压力值最大255，请自行归一化。
    func standardizeCoordinateData()->[[Track]] {
        
        let file =  Bundle.main.url(forResource: "track", withExtension: "txt")!
        let tracksData = try? String(contentsOf: file)
        
        
        let str1 = tracksData?.replacingOccurrences(of: "(", with: "")
        let codis:[String] = (str1?.components(separatedBy: ")"))!
        
        var allTracks: [[Track]] = []
            
        var isStartPoint = true //开始绘画
        var isEndPoint = false //结束绘画
        var WhitespacesAndNewlines = true

        let scale:CGFloat = 3//UIScreen.main.scale

        var tracks: [Track] = []

        for cod in codis {

            if cod == "  \n" {//最后一行换行，不处理
                isEndPoint = true
            } else {
                let c = cod.components(separatedBy: ",")
                let whitespace = NSCharacterSet.whitespacesAndNewlines
                let x = c[0].trimmingCharacters(in: whitespace)
                let y = c[1].trimmingCharacters(in: whitespace)
                let p = c[2].trimmingCharacters(in: whitespace)
                let dot = Dot(originX: CGFloat(Float(x)!)/scale, originY: CGFloat(Float(y)!)/scale, pressure:scale * CGFloat(Float(p)!-32)/255.0)
                               
                if isStartPoint {//开始绘画，定起点
                    isStartPoint = false
                    tracks.append(.MoveTo(dot: dot))
                } else {//绘画过程中，根据换行符，确定是否下一笔画的起点
                    if cod.hasPrefix("\n"){
                        WhitespacesAndNewlines = true
                    } else {
                        WhitespacesAndNewlines = false
                    }
                    if WhitespacesAndNewlines {
                        allTracks.append(tracks)
                        tracks = []
                        tracks.append(.MoveTo(dot: dot))
                    } else {
                        tracks.append(.AddTo(dot: dot))
                    }
                }
            }
        }
        return allTracks
    }

}

extension ViewController: UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.lineView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {

    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print(scale)
        //解决放大后内容锯齿问题
        view?.contentScaleFactor = scale
    }
}

