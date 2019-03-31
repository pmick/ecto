//
//  ChatViewController.swift
//  Ecto
//
//  Created by Patrick Mick on 3/31/19.
//

import EctoKit
import IGListKit
import UIKit

final class ChatViewController: UIViewController {
    private var chatController: TwitchIRCController!
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var listAdapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    private var chatMessages: [ChatMessageViewModel] = [] {
        didSet {
            listAdapter.performUpdates(animated: true) { (finished) in
                if finished {
                    let contentHeight = self.collectionView.contentSize.height
                    let containerHeight = self.collectionView.bounds.size.height
                    if contentHeight > containerHeight {
                        self.collectionView.setContentOffset(CGPoint(x: 0, y: contentHeight - containerHeight), animated: true)
                    }
                }
            }
        }
    }

    init(channelName: String) {
        super.init(nibName: nil, bundle: nil)
        chatController = TwitchIRCController(oauthToken: Environment.oauthToken,
                                             nickname: "tree2110",
                                             channelName: channelName,
                                             messagesReceivedHandler: { [unowned self] messages in
                                                self.handleNewMessages(messages)
        })
        
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        collectionView.constrainFillingSuperview()
        
        listAdapter.dataSource = self
        listAdapter.collectionView = collectionView
    }
    
    private func handleNewMessages(_ messages: [IRCPrivateMessage]) {
        let newViewModels = messages.map { message -> ChatMessageViewModel in
            let attributedMessage = NSMutableAttributedString(string: "")
            attributedMessage.append(NSAttributedString(string: message.username, attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                                                                                               .foregroundColor: message.userColor ?? UIColor.white]))
            attributedMessage.append(NSAttributedString(string: ": \(message.body)", attributes: [.font: UIFont.systemFont(ofSize: 18)]))
            return ChatMessageViewModel(message: attributedMessage)
        }
        DispatchQueue.main.async {
            self.chatMessages.append(contentsOf: newViewModels)
        }
    }
}

final class ChatMessageCollectionViewCell: UICollectionViewCell {
    private lazy var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        label.constrainFillingSuperview()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        label.numberOfLines = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindViewModel(_ viewModel: ChatMessageViewModel) {
        label.attributedText = viewModel.message
    }
}

final class ChatMessageViewModel: ListDiffable {
    let message: NSAttributedString
    
    init(message: NSAttributedString) {
        self.message = message
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return message
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
}

final class ChatMessageSectionController: ListGenericSectionController<ChatMessageViewModel> {
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let context = collectionContext else { return UICollectionViewCell() }
        let cell = context.dequeueReusableCell(of: ChatMessageCollectionViewCell.self, for: self, at: index) as! ChatMessageCollectionViewCell
        if let object = object {
            cell.bindViewModel(object)
        }
        return cell
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let context = collectionContext,
            let object = object else { return .zero }
        let width = context.containerSize.width
        let rect = object.message.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: [], context: nil)
        return CGSize(width: context.containerSize.width, height: ceil(rect.height))
    }
}

extension ChatViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return chatMessages
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return ChatMessageSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
