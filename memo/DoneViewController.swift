//
//  Done.swift
//  memo
//
//  Created by Jongbum Lee on 2023/08/02.
//
import UIKit

class DoneViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    
    // 완료된 할 일만 필터링
    var doneTodos: [TodoItem] {
        return globalTodoList.filter { $0.isCompleted }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 레이아웃 설정
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width, height: 50) // 셀 크기 조절
        
        // 컬렉션 뷰 초기화 및 설정
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "doneCell")
        view.addSubview(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return doneTodos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "doneCell", for: indexPath)
        let todo = doneTodos[indexPath.row]
        
        // 셀 내부에 레이블 추가
        let label = UILabel(frame: cell.bounds)
        label.text = todo.title
        label.textAlignment = .center
        // 완료되었을 경우 취소선
        let attributedString = NSMutableAttributedString(string: todo.title)
        if todo.isCompleted {
            attributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: todo.title.count))
        }
        label.attributedText = attributedString
        cell.contentView.addSubview(label)
        
        return cell
    }
}
