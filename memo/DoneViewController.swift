//
//  Done.swift
//  memo
//
//  Created by Jongbum Lee on 2023/08/02.
//
import UIKit

class DoneViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    
    private var doneTodos: [TodoItem] {
        return UserDefaults.standard.getTodoList().filter { $0.isCompleted }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        NotificationCenter.default.addObserver(self, selector: #selector(handleTodoItemDeleted), name: Notification.Name("TodoItemDeleted"), object: nil)
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width, height: 70)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "doneCell")
        view.addSubview(collectionView)
    }
    
    @objc private func handleTodoItemDeleted() {
        collectionView.reloadData()
    }
    
    private func configureCell(_ cell: UICollectionViewCell, with todo: TodoItem) {
        let titleLabel = createLabel(in: cell, text: todo.title, yPosition: 5)
        let categoryLabel = createLabel(in: cell, text: "Category: \(todo.category.rawValue)", yPosition: 35, textColor: .gray)
        
        cell.contentView.addSubview(titleLabel)
        cell.contentView.addSubview(categoryLabel)
        
        let separatorView = UIView(frame: CGRect(x: 0, y: cell.bounds.height - 1, width: cell.bounds.width, height: 1))
        separatorView.backgroundColor = .lightGray
        cell.contentView.addSubview(separatorView)
    }
    
    private func createLabel(in cell: UICollectionViewCell, text: String, yPosition: CGFloat, textColor: UIColor = .black) -> UILabel {
        let label = UILabel(frame: CGRect(x: 15, y: yPosition, width: cell.bounds.width - 30, height: 30))
        label.text = text
        label.textColor = textColor
        label.textAlignment = .left
        return label
    }
}

// MARK: - UICollectionView DataSource
extension DoneViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return doneTodos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "doneCell", for: indexPath)
        configureCell(cell, with: doneTodos[indexPath.row])
        return cell
    }
}

// MARK: - UICollectionView Delegate
extension DoneViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let todoDetailViewController = storyboard.instantiateViewController(withIdentifier: "TodoDetailViewController") as? TodoDetailViewController else { return }
        todoDetailViewController.todoItem = doneTodos[indexPath.row]
        navigationController?.pushViewController(todoDetailViewController, animated: true)
    }
}

