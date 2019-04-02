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
    private lazy var backgroundBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraDark))
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var listAdapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    private let emoteCache = NSCache<NSString, UIImage>()
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(backgroundBlurView)
        backgroundBlurView.constrainFillingSuperview()
        
        view.addSubview(collectionView)
        collectionView.constrainFillingSuperview()
        
        listAdapter.dataSource = self
        listAdapter.collectionView = collectionView
    }
    
    private func handleNewMessages(_ messages: [IRCPrivateMessage]) {
        let newViewModels = messages.map { message -> ChatMessageViewModel in
            // last component seems to be screen scale -- get it from tv screen. twitch web on my mbp uses 2.0
            // https://static-cdn.jtvnw.net/emoticons/v1/<emote_id>/3.0
            let attributedMessage = NSMutableAttributedString(string: "")
            attributedMessage.append(NSAttributedString(string: message.username, attributes: [.font: Constants.chatMessageAuthorFont,
                                                                                               .foregroundColor: message.userColor ?? UIColor.randomUserColor]))
            attributedMessage.append(NSAttributedString(string: ": ", attributes: [.font: Constants.chatMessageFont]))
            // flatten emote descriptors into a single array of range/emoteId
            // sort the ranges by start index because we know they don't overlap
            // once a range is applied we append the ranges length to some var that is applied to future ranges "offset"
            let emoteViewModels = message.emoteMetadata.emoteDescriptors
                .map { descriptor in return descriptor.ranges.map { (NSRange($0), descriptor.emoteId) } }
                .flatMap { $0 }
                .sorted(by: { $0.0.location < $1.0.location }) // sort by where the ranges start. It's not possible for them to overlap
            
            let emoteDescriptors = message.emoteMetadata.emoteDescriptors
            if emoteDescriptors.count > 0 {
                let attributedBody = NSMutableAttributedString(string: message.body, attributes: [.font: Constants.chatMessageFont])
                
                var offset = 0
                for emote in emoteViewModels {
                    // TODO: This should be async
                    let attachment = NSTextAttachment()
                    let image = UIImage(data: try! Data(contentsOf: URL(string: "https://static-cdn.jtvnw.net/emoticons/v1/\(emote.1)/\(UIScreen.main.scale)")!))!
                    attachment.image = image
                    attachment.bounds = CGRect(origin: .zero, size: CGSize(width: image.size.width / 2, height: image.size.height / 2))
                    let denormalizedRange = emote.0
                    let normalizedRange = NSRange(location: denormalizedRange.location - offset, length: denormalizedRange.length)
                    attributedBody.replaceCharacters(in: normalizedRange, with: NSAttributedString(attachment: attachment))
                    offset += (emote.0.length - 1)
                }
                
                attributedMessage.append(attributedBody)
            } else {
                attributedMessage.append(NSAttributedString(string: message.body, attributes: [.font: Constants.chatMessageFont]))
            }
            
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
        let width = context.containerSize.width
        let measurementCell = ChatMessageSectionController.measurementCell
        measurementCell.bindViewModel(object)
        let size = measurementCell.contentView.systemLayoutSizeFitting(CGSize(width: width, height: 10_000),
                                                                       withHorizontalFittingPriority: .required,
                                                                       verticalFittingPriority: .fittingSizeLevel)
        
        return CGSize(width: width, height: ceil(size.height))
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
