import UIKit

protocol TaskTableViewCellDelegate: AnyObject {
    func didTapChecker(for task: Task)
}

class TaskTableViewCell: UITableViewCell {
    
    weak var delegate: TaskTableViewCellDelegate?
    
    private var task: Task?
    
    // MARK: - UI элементы
    private let checkerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 1
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Инициализация
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .black
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Настройка UI Layout
    private func setupLayout() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapChecker))
        checkerImageView.addGestureRecognizer(tapRecognizer)
        checkerImageView.isUserInteractionEnabled = true // Включаем взаимодействие
        
        contentView.addSubview(checkerImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            checkerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            checkerImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            checkerImageView.widthAnchor.constraint(equalToConstant: 24),
            checkerImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.centerYAnchor.constraint(equalTo: checkerImageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: checkerImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Конфигурация ячейки
    func configure(with task: Task) {
        self.task = task
        
        if task.completed {
            let attributedString = NSAttributedString(
                string: task.todo,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.gray
                ]
            )
            titleLabel.attributedText = attributedString
        } else {
            let attributedString = NSAttributedString(
                string: task.todo,
                attributes: [
                    .foregroundColor: UIColor.white
                ]
            )
            titleLabel.attributedText = attributedString
        }
        
        descriptionLabel.text = task.description
        descriptionLabel.textColor = task.completed ? .gray : .white
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        dateLabel.text = dateFormatter.string(from: task.date ?? Date.now)
        dateLabel.textColor = task.completed ? .gray : .lightGray
        
        if task.completed {
                checkerImageView.image = UIImage(systemName: "checkmark.circle")
                checkerImageView.tintColor = .systemYellow
            } else {
                checkerImageView.image = UIImage(systemName: "circle")
                checkerImageView.tintColor = .lightGray
            }
    }
    
    @objc private func didTapChecker() {
        guard let task = task else { return }
        delegate?.didTapChecker(for: task)
    }
}
