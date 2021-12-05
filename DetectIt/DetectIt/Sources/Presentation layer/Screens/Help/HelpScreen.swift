//
//  HelpScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 21/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItCore

final class HelpScreen: Screen {
    
    private let closeButton = SolidButton.closeButton()
    
    private let contentContainer = StackViewController()
    
    private let titleLabel = UILabel()
    private let textLabel = UILabel()
    
    private let taskKind: TaskKind
    
    init(taskKind: TaskKind) {
        self.taskKind = taskKind
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    override func loadView() {
        super.loadView()
        
        isStatusBarBlurred = true
        
        setupViews()
    }
    
    override func prepare() {
        super.prepare()
        
        titleLabel.text = taskKind.title
        
        switch taskKind {
        case .cipher:
            textLabel.attributedText = decoderTaskText.readableAttributedText(font: textLabel.font)
        case .profile:
            textLabel.attributedText = profileTaskText.readableAttributedText(font: textLabel.font)
        case .blitz:
            textLabel.attributedText = blitzTaskText.readableAttributedText(font: textLabel.font)
        case .quest:
            textLabel.attributedText = questTaskText.readableAttributedText(font: textLabel.font)
        }
    }
    
    @objc private func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupViews() {
        contentContainer.place(into: self)
        
        contentContainer.stackView.layoutMargins = UIEdgeInsets(
            top: 52, left: .hInset, bottom: 20, right: .hInset
        )
        
        contentContainer.appendChild(titleLabel)
        contentContainer.appendSpacing(20)
        contentContainer.appendChild(textLabel)
        
        titleLabel.font = .heading1
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        textLabel.font = .text3
        textLabel.textColor = .white
        textLabel.numberOfLines = 0
        
        view.addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    private let decoderTaskText =
    """
    В заданиях этого типа необходимо разгадывать зашифрованные сообщения.

    В качестве способа шифрования может быть что угодно - шифр Цезаря, метафора, ассоциация и т.д.

    В некоторых шифрах не только можно, но и нужно использовать интернет.

    Внимательно читайте задание - в нем содержится очень важная информация.

    Учтите, что ответ нужно записывать так, как требуется в задании, без ошибок и соблюдая пунктуацию.

    И самое главное - второго шанса у вас нет. Тщательно обдумывайте и проверяйте ответ.
    """
    
    private let profileTaskText =
    """
    В расследовании вам предстоит ознакомиться с историей преступления, а в конце заполнить отчет, состоящий из нескольких вопросов.

    Дела, с которыми вы столкнетесь, могут быть основаны на реальных событиях, но, если у вас получится найти информацию в интернете, она вам ничем не поможет, так как она послужила всего лишь основой.

    Старайтесь не упускать деталей. К верным ответам может привести что угодно - название дела, предыстория или прикрепленные файлы.

    Верных ответов в интернете не найти, но можно узнать некоторую полезную информацию. Если вам встретится непонятное обозначение - поищите в сети.

    Будьте внимательны при написании текстовых ответов. Важно придерживаться формата, указанного в вопросе, не писать ничего лишнего и не делать ошибок.

    И самое главное - второго шанса у вас нет. Тщательно обдумывайте и проверяйте ответы.
    """
    
    private let blitzTaskText =
    """
    Блиц – это короткое расследование, содержащее всего один вопрос. Но от этого оно не становится легче обычного расследования.
    
    Ищите ответ на вопрос где угодно – в тексте задания, интернете, между строк. Любые средства могут дать наводку.
    
    И самое главное - второго шанса у вас нет. Тщательно обдумывайте и проверяйте ответ.
    """
    
    private let questTaskText =
    """
    Квест - это интерактивное расследование, где история раскрывается постепенно и имеет несколько концовок.

    Судьба расследования в ваших руках - обдумывайте дальнейшие действия, так как изменить прошлое не получится.

    Количество баллов зависит от того, какую концовку вы получите.
    """
    
}
