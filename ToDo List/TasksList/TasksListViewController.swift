//
//  ViewController.swift
//  ToDo List
//
//  Created by Fedor Bebinov on 17.03.2025.
//

import UIKit

protocol TasksListViewControllerProtocol: AnyObject{
    func reloadData()
    func updateSearchBar(with text: String)
    func showError(message: String)
    func setMicButtonState(isListening: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func displayError(_ message: String)
}

class TasksListViewController: UIViewController, TasksListViewControllerProtocol {
    
    private let presenter: TasksListPresenterProtocol
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    private lazy var header: UILabel = {
        let label = UILabel()
        label.text = "Задачи"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 34)
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.layer.cornerRadius = 10
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.returnKeyType = .search
        
        if let searchTextField = searchBar.value(forKey: "searchField") as? UITextField {
            searchTextField.textColor = .white
            searchTextField.tintColor = .systemYellow
            searchTextField.backgroundColor = UIColor(red: 39/255, green: 39/255, blue: 41/255, alpha: 1.0)
            
            let placeholderText = "Search"
            searchTextField.attributedPlaceholder = NSAttributedString(
                string: placeholderText,
                attributes: [.foregroundColor: UIColor.lightGray]
            )
            

            if let leftView = searchTextField.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = .lightGray
            }
            
            if let clearButton = searchTextField.rightView as? UIButton {
                clearButton.setImage(clearButton.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
                clearButton.tintColor = .lightGray
            }
        }
        
        return searchBar
    }()
    
    private lazy var micButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        let micImage = UIImage(systemName: "mic.fill")?.withRenderingMode(.alwaysTemplate)
        button.setImage(micImage, for: .normal)
        button.tintColor = .lightGray
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(didTapMicButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var tasksTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: "TaskTableViewCell")
        tableView.backgroundColor = .black
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.lightGray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20) // Отступы слева и справа
        return tableView
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "0 задач"
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.tintColor = .systemYellow
        button.addTarget(self, action: #selector(didTapAddTaskButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var footerView: UIView = {
        let footerView = UIView()
        footerView.backgroundColor = UIColor(red: 39/255, green: 39/255, blue: 41/255, alpha: 1.0)
        footerView.translatesAutoresizingMaskIntoConstraints = false
        return footerView
    }()
    
    init(presenter: TasksListPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        view.addSubview(header)
        view.addSubview(searchBar)
        view.addSubview(tasksTableView)
        view.addSubview(footerView)
        footerView.addSubview(countLabel)
        footerView.addSubview(addButton)
        guard let textField = searchBar.value(forKey: "searchField") as? UITextField else {
            return
        }
        textField.addSubview(micButton)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchBar.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            micButton.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -8),
            micButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            micButton.widthAnchor.constraint(equalToConstant: 24),
            micButton.heightAnchor.constraint(equalToConstant: 24),
            
            tasksTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            tasksTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tasksTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tasksTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 83),
            
            countLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 20),
            
            addButton.centerYAnchor.constraint(equalTo: countLabel.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -30),
            addButton.widthAnchor.constraint(equalToConstant: 24),
            addButton.heightAnchor.constraint(equalToConstant: 24),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func reloadData() {
        tasksTableView.reloadData()
        countLabel.text = "\(presenter.tasksCount) задач"
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func displayError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    func updateSearchBar(with text: String) {
        searchBar.text = text
        //let micImageName = presenter.isListening ? "mic.circle.fill" : "mic.fill"
        //micButton.setImage(UIImage(systemName: micImageName), for: .normal)
    }
    
    func setMicButtonState(isListening: Bool) {
        let micImageName = isListening ? "mic.circle.fill" : "mic.fill" // Слушает или нет
        micButton.setImage(UIImage(systemName: micImageName), for: .normal)
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func didTapAddTaskButton() {
        print("Новая задача создана!")
    }
    
    @objc private func didTapMicButton() {
        presenter.toggleVoiceRecognition()
    }
}

extension TasksListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.tasksCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as? TaskTableViewCell else {
            fatalError("Could not dequeue TaskTableViewCell")
        }
        let task = presenter.task(at: indexPath.row)
        cell.delegate = self
        cell.configure(with: task)
        return cell
    }
}

extension TasksListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectTask(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil,
                                          actionProvider: {
            suggestedActions in
            let editAction =
            UIAction(title: NSLocalizedString("Редактировать", comment: ""),
                     image: UIImage(systemName: "arrow.up.square")) { action in
                //self.performInspect(indexPath)
            }
            let shareAction =
            UIAction(title: NSLocalizedString("Поделиться", comment: ""),
                     image: UIImage(systemName: "plus.square.on.square")) { action in
                //self.performDuplicate(indexPath)
            }
            let deleteAction =
            UIAction(title: NSLocalizedString("Удалить", comment: ""),
                     image: UIImage(systemName: "trash"),
                     attributes: .destructive) { action in
                //self.performDelete(indexPath)
            }
            return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
        })
    }
    
}

extension TasksListViewController: TaskTableViewCellDelegate {
    func didTapChecker(for task: Task) {
        presenter.toggleTaskCompletion(for: task)
        
        guard let index = presenter.indexForTask(task) else { return }
        
        tasksTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
}

extension TasksListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.searchTasks(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
