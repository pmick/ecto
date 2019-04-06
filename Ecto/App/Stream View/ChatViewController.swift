//
//  ChatViewController.swift
//  Ecto
//
//  Created by Patrick Mick on 3/31/19.
//

import EctoKit
import IGListKit
import UIKit

extension UIColor {
    static var randomUserColor: UIColor {
        let colors: [UIColor] = [.red, .green, .yellow, .orange, .purple, .magenta, .cyan, .brown].shuffled()
        return colors[0]
    }
}

final class ChatViewController: UIViewController {
    private enum Constants {
        static let chatMessageFont = UIFont.systemFont(ofSize: 20)
        static let chatMessageAuthorFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
    }
    
    private var chatController: TwitchIRCController!
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var listAdapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    private let chatMessageQueue = DispatchQueue(label: "com.patrickmick.ecto.emotes")
    private let chatMessageViewModelFactory = ChatMessageViewModelFactory()
    private var chatMessages: [ChatMessageViewModel] = [] {
        didSet {
            listAdapter.performUpdates(animated: false) { (finished) in
                let contentHeight = self.collectionView.contentSize.height
                let containerHeight = self.collectionView.bounds.size.height
                if contentHeight > containerHeight {
                    self.collectionView.setContentOffset(CGPoint(x: 0, y: contentHeight - containerHeight), animated: false)
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        view.addSubview(collectionView)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.constrainFillingSuperview()
        
        listAdapter.dataSource = self
        listAdapter.collectionView = collectionView
    }
    
    private func handleNewMessages(_ messages: [IRCPrivateMessage]) {
        chatMessageQueue.async {
            let newViewModels = messages.map(self.chatMessageViewModelFactory.makeChatMessageViewModel)
            DispatchQueue.main.sync {
                var copy = self.chatMessages
                copy.append(contentsOf: newViewModels)
                self.chatMessages = Array(copy.suffix(50))
            }
        }
    }
}

final class ChatMessageCollectionViewCell: UICollectionViewCell {
    private lazy var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(label)
        label.constrainFillingSuperview(margins: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
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

final class ChatMessageSizeCache {
    static let `default` = ChatMessageSizeCache()
    
    private var cache: [String: CGSize] = [:]
    private let queue = DispatchQueue(label: "com.patrickmick.ecto.chat-message-size-cache")
    
    func set(_ size: CGSize, forKey key: String) {
        queue.sync {
            cache[key] = size
        }
    }
    
    func getSize(forKey key: String) -> CGSize? {
        return queue.sync {
            return cache[key]
        }
    }
}

final class ChatMessageSectionController: ListGenericSectionController<ChatMessageViewModel> {
    private static let measurementCell = ChatMessageCollectionViewCell(frame: .zero)
    
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
        
        if let cachedSize = ChatMessageSizeCache.default.getSize(forKey: object.message.string) {
            return cachedSize
        }
        
        let width = context.containerSize.width
        let measurementCell = ChatMessageSectionController.measurementCell
        measurementCell.bindViewModel(object)
        
        let size = measurementCell.contentView.systemLayoutSizeFitting(CGSize(width: width, height: 10_000),
                                                                       withHorizontalFittingPriority: .required,
                                                                       verticalFittingPriority: .fittingSizeLevel)
        
        let normalizedSize = CGSize(width: width, height: ceil(size.height))
        ChatMessageSizeCache.default.set(normalizedSize, forKey: object.message.string)
        return normalizedSize
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
