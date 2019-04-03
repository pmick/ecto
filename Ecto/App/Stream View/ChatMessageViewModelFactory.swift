//
//  ChatMessageViewModelFactory.swift
//  Ecto
//
//  Created by Patrick Mick on 4/2/19.
//

import EctoKit
import Foundation
import IGListKit

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

final class ChatMessageViewModelFactory {
    private enum Constants {
        static let chatMessageFont = UIFont.systemFont(ofSize: 20)
        static let chatMessageAuthorFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
    }
    
    private let emoteCache = NSCache<NSString, UIImage>()
    
    func makeChatMessageViewModel(from message: IRCPrivateMessage) -> ChatMessageViewModel {
        return ChatMessageViewModel(message: makeChatMessageAttributedString(from: message))
    }
    
    private func makeChatMessageAttributedString(from message: IRCPrivateMessage) -> NSAttributedString {
        let attributedMessage = NSMutableAttributedString(string: "")
        attributedMessage.append(nameAttributedString(from: message))
        attributedMessage.append(separatorAttributedString())
        attributedMessage.append(messageAttributedString(from: message))
        return attributedMessage
    }
    
    private func nameAttributedString(from message: IRCPrivateMessage) -> NSAttributedString {
        return NSAttributedString(string: message.username, attributes: [.font: Constants.chatMessageAuthorFont,
                                                                         .foregroundColor: message.userColor ?? UIColor.randomUserColor])
    }
    
    private func separatorAttributedString() -> NSAttributedString {
        return NSAttributedString(string: ": ", attributes: [.font: Constants.chatMessageFont])
    }
    
    private func messageAttributedString(from message: IRCPrivateMessage) -> NSAttributedString {
        let emoteViewModels = message.emoteMetadata.emoteDescriptors
            .map { descriptor in return descriptor.ranges.map { (NSRange($0), descriptor.emoteId) } }
            .flatMap { $0 }
            .sorted(by: { $0.0.location < $1.0.location }) // sort by where the ranges start. It's not possible for them to overlap
        
        let emoteDescriptors = message.emoteMetadata.emoteDescriptors
        guard emoteDescriptors.count > 0 else { return NSAttributedString(string: message.body, attributes: [.font: Constants.chatMessageFont]) }
        let attributedBody = NSMutableAttributedString(string: message.body, attributes: [.font: Constants.chatMessageFont])
        
        var offset = 0
        for emote in emoteViewModels {
            let attachment = makeTextAttachment(forEmoteWithId: emote.1)
            let denormalizedRange = emote.0
            let normalizedRange = NSRange(location: denormalizedRange.location - offset, length: denormalizedRange.length)
            attributedBody.replaceCharacters(in: normalizedRange, with: NSAttributedString(attachment: attachment))
            offset += (emote.0.length - 1)
        }
        
        return attributedBody
    }
    
    private func makeTextAttachment(forEmoteWithId emoteId: String) -> NSTextAttachment {
        let attachment = NSTextAttachment()
        let image = self.fetchCachedOrDownload(forEmoteWithId: emoteId)
        attachment.image = image
        attachment.bounds = CGRect(origin: .zero, size: CGSize(width: image.size.width / 2, height: image.size.height / 2))
        return attachment
    }
    
    /// Blocks the calling thread for image downloads if we actually have to hit the network
    private func fetchCachedOrDownload(forEmoteWithId emoteId: String) -> UIImage {
        if let cachedImage = emoteCache.object(forKey: emoteId as NSString) {
            return cachedImage
        } else {
            do {
                guard let url = URL(string: "https://static-cdn.jtvnw.net/emoticons/v1/\(emoteId)/\(UIScreen.main.scale)"),
                    let image = UIImage(data: try Data(contentsOf: url)) else { return UIImage() }
                emoteCache.setObject(image, forKey: emoteId as NSString)
                return image
            } catch {
                return UIImage()
            }
        }
    }
}
