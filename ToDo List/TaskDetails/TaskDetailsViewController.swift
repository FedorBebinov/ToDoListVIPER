import UIKit

class TaskDetailsViewController: UIViewController {
    private var task: Task
    private let delegate: TaskDetailsViewControllerDelegate

    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Заголовок задачи"
        textField.textColor = .white
        textField.backgroundColor = UIColor(red: 39/255, green: 39/255, blue: 41/255, alpha: 1.0)
        textField.layer.cornerRadius = 10
        textField.padding(10) // Метод для добавления отступа (добавьте реализацию)
        return textField
    }()

    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = .white
        textView.backgroundColor = UIColor(red: 39/255, green: 39/255, blue: 41/255, alpha: 1.0)
        textView.layer.cornerRadius = 10
        return textView
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Сохранить", for: .normal)
        button.addTarget(self, action: #selector(saveTask), for: .touchUpInside)
        return button
    }()
    
    init(task: Task, delegate: TaskDetailsViewControllerDelegate) {
        self.task = task
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        titleTextField.text = task.todo
        descriptionTextView.text = task.description ?? ""
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
    }

    private func setupUI() {
        view.addSubview(titleTextField)
        view.addSubview(descriptionTextView)
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),

            descriptionTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            descriptionTextView.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 200),

            saveButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func saveTask() {
        let updatedTask = Task(id: task.id, todo: titleTextField.text ?? "", completed: task.completed, userId: task.userId, date: task.date, description: descriptionTextView.text)
        delegate.didUpdateTask(updatedTask)
        navigationController?.popViewController(animated: true) // Возврат на предыдущий экран
    }
}

protocol TaskDetailsViewControllerDelegate: AnyObject {
    func didUpdateTask(_ task: Task)
}
