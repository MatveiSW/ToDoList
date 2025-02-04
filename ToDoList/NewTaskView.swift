//
//  NewTaskView.swift
//  ToDoList
//
//  Created by Матвей Авдеев on 04.02.2025.
//

import UIKit

final class NewTaskView: UIView {
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.left")
        button.setImage(image, for: .normal)
        button.setTitle("Назад", for: .normal)
        button.tintColor = .systemYellow
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.tintColor = .systemYellow
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.font = .systemFont(ofSize: 34, weight: .bold)
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()
    
    var onBackButtonTap: (() -> Void)?
    var onDoneButtonTap: (() -> Void)?
    
    var hasChanges: Bool {
        return !textView.text.isEmpty
    }
    
    var taskTitle: String? {
        let components = textView.text.components(separatedBy: "\n")
        return components.first
    }
    
    var taskDescription: String? {
        let components = textView.text.components(separatedBy: "\n")
        if components.count > 1 {
            return components.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .black
        
        addSubview(backButton)
        addSubview(doneButton)
        addSubview(dateLabel)
        addSubview(textView)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            doneButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            textView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        
        textView.becomeFirstResponder()
    }
    
    @objc private func backButtonTapped() {
        onBackButtonTap?()
    }
    
    @objc private func doneButtonTapped() {
        onDoneButtonTap?()
    }
    
    private func updateDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        dateLabel.text = dateFormatter.string(from: Date())
    }
    
    func setText(_ text: String) {
        textView.text = text
        textViewDidChange(textView)
    }
}

// MARK: - UITextViewDelegate
extension NewTaskView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if dateLabel.text?.isEmpty ?? true {
            updateDate()
        }
        
        doneButton.isEnabled = !textView.text.isEmpty
        
        let attributedText = NSMutableAttributedString(string: textView.text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        
        attributedText.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: attributedText.length))
        
        attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 17), range: NSRange(location: 0, length: attributedText.length))
        
        if let firstLineRange = textView.text.range(of: "^[^\n]*", options: .regularExpression) {
            let nsRange = NSRange(firstLineRange, in: textView.text)
            attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 34, weight: .bold), range: nsRange)
        }
        
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
        
        let selectedRange = textView.selectedRange
        textView.attributedText = attributedText
        textView.selectedRange = selectedRange
        
        if let currentLine = getCurrentLine(in: textView) {
            textView.typingAttributes = [
                .font: currentLine == 0 ? UIFont.systemFont(ofSize: 34, weight: .bold) : UIFont.systemFont(ofSize: 17),
                .foregroundColor: UIColor.white
            ]
        }
    }
    
    private func getCurrentLine(in textView: UITextView) -> Int? {
        let cursorPosition = textView.selectedRange.location
        let text = textView.text as NSString
        var lineNumber = 0
        
        text.enumerateSubstrings(in: NSRange(location: 0, length: text.length), 
                                options: [.byLines]) { _, range, _, stop in
            if cursorPosition >= range.location && cursorPosition <= range.location + range.length {
                stop.pointee = true
                return
            }
            lineNumber += 1
        }
        
        return lineNumber
    }
}
