//
//  ChocolatesOfTheWorldViewController.swift
//  Chocotastic
//
//  Created by 周登杰 on 2019/10/26.
//  Copyright © 2019 zdj. All rights reserved.
//

import UIKit
import RxSwift

class ChocolatesOfTheWorldViewController: UIViewController {
    
    @IBOutlet private var cartButton: UIBarButtonItem!
    @IBOutlet private var tableView: UITableView!
    
    //just(:)方法不会对Observable对象的底层值做任何修改，但你仍然需要你Observable值的方式来访问它
    let europeanChocolates = Observable.just(Chocolate.ofEurope)
    
    //用于确保设置的Observer在deinit()中被清理掉
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Chocolate!!!"
        
        setupCellConfiguration()
        setupCellTapHandling()
//        tableView.dataSource = self
//        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCartObserver()
    }
    
//    func updateCartButton() {
//        cartButton.title = "\(ShoppingCart.sharedCart.chocolates.value.count)🍫"
//    }
    
    //MARK: Rx Setup
    //设置响应式的Observer来自动更新购物车
    private func setupCartObserver(){
        // 1、将chocolates变量作为一个Observable
        ShoppingCart.sharedCart.chocolates.asObservable()
            // 2、订阅Observable的值的变化
            .subscribe(onNext: { (chocolates) in
                self.cartButton.title = "\(chocolates.count) 🍫"
            }, onError: { (error) in
                print(error.localizedDescription)
            }, onCompleted: {
                print("onCompleted")
            }) {
                print("onDispose")
        }
            //3、将Observer对象添加到disposeBag中，确保在订阅对象被释放时我们的订阅被丢弃
            .addDisposableTo(disposeBag)
    }
    
    private func setupCellConfiguration() {
        //1
        europeanChocolates
            //将europeanChocolates observer关联到应该为tableView每一行执行的代码
        .bindTo(tableView
            //调用rx，你可以访问任何类的RxCocoa扩展-在这里是UItableview
            .rx//2
            //调用Rx的items(cellIdentifier:cellType:)方法，传入单元格标识符及要使用的单元格类型。这让框架可以调用出列方法(dequeuing methods)，如果你的tableview仍然有原始的代理，这些方法也会被正常调用
            .items(cellIdentifier: ChocolateCell.Identifier,
                   cellType: ChocolateCell.self)){//3
                    //传入一个为每个单元格执行的闭包，
        (row, chocolate, cell) in
                    cell.configureWithChocolate(chocolate: chocolate)//4
        }
            //获取到bindTo(_:)返回的Disposable，然后添加到disposeBag
    .addDisposableTo(disposeBag) //5
    }
    
    private func setupCellTapHandling() {
     tableView
        .rx
        .modelSelected(Chocolate.self)//1,调用tableview的响应式方法modelSelected(_:)，传入Chocolate模型以获取项目的正确类型，这个方法返回一个Observable
        .subscribe(onNext: { //2,获取Observable后，调用subscribe(onNext:)方法，传入一个尾随闭包，在模型被选中时会调用这个闭包
            (chocolate) in
            ShoppingCart.sharedCart.chocolates.value.append(chocolate)//3，在尾随闭包中，将选中的巧克力添加到购物车中
            
            if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
            }//4，确保当前被点击的单元格选中状态被取消
        }, onError: { (error) in
            print(error.localizedDescription)
        }, onCompleted: {
            print("onCompleted")
        }) {
            print("onDispose")
        }
        //5，将返回的Disposable添加到disposeBag
    .addDisposableTo(disposeBag)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

/*
extension ChocolatesOfTheWorldViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return europeanChocolates.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChocolateCell.Identifier, for: indexPath) as? ChocolateCell else { return UITableViewCell() }
        
        let chocolate = europeanChocolates[indexPath.row]
        cell.configureWithChocolate(chocolate: chocolate)
        
        return cell
    }
}

extension ChocolatesOfTheWorldViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let chocolate = europeanChocolates[indexPath.row]
        ShoppingCart.sharedCart.chocolates.value.append(chocolate)
        
        setupCartObserver()
    }
}
*/


extension ChocolatesOfTheWorldViewController:
SegueHandler {
    enum SegueIdentifier: String {
        case
        GoToCart
    }
}
