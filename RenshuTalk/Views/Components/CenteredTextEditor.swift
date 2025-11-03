


import SwiftUI

struct CenteredTextEditor: UIViewRepresentable {
    @Binding var text: String
    var fontSize: CGFloat
    var maxWidth: CGFloat = 300
    var horizontalPadding: CGFloat = 20
    var placeholder: String = "Write here..."
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.textAlignment = .center
        textView.font = UIFont.systemFont(ofSize: fontSize)
        textView.textColor = .label
        textView.textContainer.lineFragmentPadding = horizontalPadding
        textView.textContainerInset = .zero
        textView.isScrollEnabled = false
        textView.setContentOffset(.zero, animated: false)
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.autocorrectionType = .default
        textView.autocapitalizationType = .sentences
        
        textView.text = placeholder
                textView.textColor = UIColor.gray.withAlphaComponent(0.5)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
            // Atualiza texto apenas se for diferente e não placeholder
            if uiView.text != text && !(uiView.textColor == UIColor.gray.withAlphaComponent(0.5) && text.isEmpty) {
                uiView.text = text
                uiView.textColor = .label
            }

            uiView.textAlignment = .center
            uiView.font = UIFont.systemFont(ofSize: fontSize)
            uiView.textContainer.lineFragmentPadding = horizontalPadding
            uiView.textContainer.lineBreakMode = .byWordWrapping

            let fittingHeight = uiView.sizeThatFits(CGSize(width: uiView.frame.width, height: .infinity)).height
            let topInset = max(0, (uiView.frame.height - fittingHeight) / 2)
            uiView.textContainerInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)

            let limitedWidth = min(uiView.frame.width, maxWidth)
            let textHeight = uiView.sizeThatFits(CGSize(width: limitedWidth, height: .greatestFiniteMagnitude)).height
            let viewHeight = uiView.frame.height

            if textHeight <= viewHeight {
                let topInset = max((viewHeight - textHeight) / 2, 0)
                uiView.textContainerInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
                uiView.isScrollEnabled = false
            } else {
                uiView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                uiView.isScrollEnabled = true
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
                // Remove o placeholder ao começar a digitar
                if textView.textColor == UIColor.gray.withAlphaComponent(0.5) {
                    textView.text = ""
                    textView.textColor = .label
                }
            }

            func textViewDidEndEditing(_ textView: UITextView) {
                // Reaparece o placeholder se o campo estiver vazio
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
    }
