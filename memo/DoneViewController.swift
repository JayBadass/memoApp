//
//  Done.swift
//  memo
//
//  Created by Jongbum Lee on 2023/08/02.
//
import UIKit

class DoneViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var collectionView: UICollectionView!
    
    private var doneTodos: [TodoItem] {
        return globalTodoList.filter { $0.isCompleted }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        NotificationCenter.default.addObserver(self, selector: #selector(handleTodoItemDeleted), name: Notification.Name("TodoItemDeleted"), object: nil)
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width, height: 50)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "doneCell")
        view.addSubview(collectionView)
    }
    
    @objc private func handleTodoItemDeleted() {
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return doneTodos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "doneCell", for: indexPath)
        configureCell(cell, at: indexPath)
        return cell
    }
    
    private func configureCell(_ cell: UICollectionViewCell, at indexPath: IndexPath) {
        let todo = doneTodos[indexPath.row]
        
        let label = UILabel(frame: cell.bounds)
        label.text = todo.title
        label.textAlignment = .center
        cell.contentView.addSubview(label)
        
        let separatorView = UIView(frame: CGRect(x: 0, y: cell.bounds.height - 1, width: cell.bounds.width, height: 1))
        separatorView.backgroundColor = .lightGray
        cell.contentView.addSubview(separatorView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let todoDetailViewController = storyboard.instantiateViewController(withIdentifier: "TodoDetailViewController") as? TodoDetailViewController else { return }
        todoDetailViewController.todoItem = doneTodos[indexPath.row]
        navigationController?.pushViewController(todoDetailViewController, animated: true)
    }
}
