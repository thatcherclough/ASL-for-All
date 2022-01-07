//
//  WrappedHStack.swift
//  ASL for All
//
//  Created by Thatcher Clough on 8/12/21.
//  Modified from https://gist.github.com/kanesbetas/63e719cb96e644d31bf027194bf4ccdb

import SwiftUI

struct WrappedHStack<Content: View>: View {
    private let content: [Content]
    private let spacing: CGFloat
    private let width: CGFloat
    
    init<Data, ID: Hashable>(width: CGFloat, spacing: CGFloat, @ViewBuilder content: () -> ForEach<Data, ID, Content>) {
        let views = content()
        self.width = width
        self.spacing = spacing
        self.content = views.data.map(views.content)
    }
    
    var body: some View {
        let rowBuilder = RowBuilder(spacing: spacing, containerWidth: width)
        
        let rowViews = rowBuilder.generateRows(views: content)
        
        let finalView = ForEach(rowViews.indices, id:\.self) {
            rowViews[$0]
        }
        
        VStack(alignment: .center, spacing: spacing) {
            finalView
        }
        .frame(width: width)
    }
}

extension WrappedHStack {
    struct RowBuilder {
        private var spacing: CGFloat
        private var containerWidth: CGFloat
        
        init(spacing: CGFloat, containerWidth: CGFloat) {
            self.spacing = spacing
            self.containerWidth = containerWidth
        }
        
        func generateRows<Content: View>(views: [Content]) -> [AnyView] {
            var rows = [AnyView]()
            
            var currentRowViews = [AnyView]()
            var currentRowWidth: CGFloat = 0
            
            for view in views {
                let viewWidth = view.getSize().width
                
                if currentRowWidth + viewWidth > containerWidth {
                    rows.append(createRow(for: currentRowViews))
                    currentRowViews = []
                    currentRowWidth = 0
                }
                currentRowViews.append(view.erasedToAnyView())
                currentRowWidth += viewWidth + spacing
            }
            rows.append(createRow(for: currentRowViews))
            return rows
        }
        
        private func createRow(for views: [AnyView]) -> AnyView {
            HStack(alignment: .center, spacing: spacing) {
                ForEach(views.indices, id:\.self) {
                    views[$0]
                }
            }
            .erasedToAnyView()
        }
    }
}

extension View {
    func erasedToAnyView() -> AnyView {
        AnyView(self)
    }
    
    func getSize() -> CGSize {
        UIHostingController(rootView: self).view.intrinsicContentSize
    }
}
