import UIKit

protocol TaskDetailsViewProtocol: AnyObject {
    func showTask(_ task: Task)
    func setSaveEnabled(_ enabled: Bool)
}

final class TaskDetailsViewController: UIViewController {
    
    var presenter: TaskDetailsPresenterProtocol!
    weak var delegate: TaskDetailsViewControllerDelegate?
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = .white
        textField.font = UIFont.boldSystemFont(ofSize: 34)
        textField.addTarget(self, action: #selector(textFieldsChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.delegate = self
        return textView
    }()
    
    private lazy var saveBarButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(saveTask))
        barButton.isEnabled = false
        return barButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationController?.navigationBar.tintColor = .systemYellow
        navigationItem.rightBarButtonItem = saveBarButton
        setupUI()
        presenter.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        descriptionTextView.becomeFirstResponder()
    }
    
    private func setupUI() {
        view.addSubview(titleTextField)
        view.addSubview(dateLabel)
        view.addSubview(descriptionTextView)
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),
            
            dateLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 12),
            dateLabel.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            
            descriptionTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc private func saveTask() {
        presenter.didTapSave(
            newTitle: titleTextField.text ?? "",
            newDescription: descriptionTextView.text ?? "")
    }
    
    @objc private func textFieldsChanged() {
        presenter.didChangeText(
            title: titleTextField.text ?? "",
            description: descriptionTextView.text ?? "")
    }
}

extension TaskDetailsViewController: TaskDetailsViewProtocol {
    func showTask(_ task: Task) {
        titleTextField.text = task.todo
        descriptionTextView.text = task.description ?? ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        dateLabel.text = dateFormatter.string(from: task.date ?? Date())
        setSaveEnabled(false)
    }
    
    func setSaveEnabled(_ enabled: Bool) {
        saveBarButton.isEnabled = enabled
    }
}

extension TaskDetailsViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        presenter.didChangeText(
            title: titleTextField.text ?? "",
            description: descriptionTextView.text ?? "")
    }
}
