


import SwiftUI

struct CenteredTextEditor: UIViewRepresentable {
    @Binding var text: String
    var fontSize: CGFloat
    var maxWidth: CGFloat = 300
    var placeholder: String = "Write here..."
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.textAlignment = .center
        textView.font = UIFont.systemFont(ofSize: fontSize)
        //textView.textColor = .label
        textView.textContainerInset = .zero
        textView.isScrollEnabled = false
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.autocorrectionType = .default
        textView.autocapitalizationType = .sentences
        //textView.text = placeholder
        //textView.textColor = UIColor.gray.withAlphaComponent(0.5)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        textView.textContainerInset = UIEdgeInsets(
                    top: (textView.bounds.height - textView.font!.lineHeight) / 2,
                    left: 0, bottom: 0, right: 0
                )
        if text.isEmpty {
                textView.text = placeholder
                textView.textColor = UIColor.gray.withAlphaComponent(0.5)
            } else {
                textView.text = text
                textView.textColor = .label
            }
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if !uiView.isFirstResponder {
                if text.isEmpty {
                    
                    uiView.text = placeholder
                    uiView.textColor = UIColor.gray.withAlphaComponent(0.5)
                } else {
                    
                    uiView.text = text
                    uiView.textColor = .label
                }
            }
    DispatchQueue.main.async {
                let size = uiView.sizeThatFits(CGSize(width: uiView.bounds.width, height: .greatestFiniteMagnitude))
                let textHeight = size.height
                let viewHeight = uiView.bounds.height
                let topInset = max((viewHeight - textHeight) / 2, 0)
                uiView.textContainerInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
            }
        }


    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CenteredTextEditor

        init(_ parent: CenteredTextEditor) {
            self.parent = parent
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            
            if textView.textColor == UIColor.gray.withAlphaComponent(0.5) {
                textView.text = ""
                textView.textColor = .label
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            
            if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                textView.text = parent.placeholder
                textView.textColor = UIColor.gray.withAlphaComponent(0.5)
            }
        }

        
        func textViewDidChange(_ textView: UITextView) {
            
            if textView.textColor != UIColor.gray.withAlphaComponent(0.5) {
                parent.text = textView.text
            }
            
        }
    }
    
    private func fontSize(for text: String) -> CGFloat {
        let baseSize: CGFloat = 28
        let length = text.count
        
        switch length {
        case 0...50: return baseSize
        case 51...100: return baseSize * 0.9
        case 101...200: return baseSize * 0.8
        default: return baseSize * 0.7
        }
    }
}
