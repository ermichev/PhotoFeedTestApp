//
//  CustomModalSheetModifier.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 24.06.2024.
//

import SwiftUI

extension View {

    func customSheet<Interactor: AnyObject, V: View>(
        interactor: Binding<EquatableStore<Interactor>>,
        @ViewBuilder view: @escaping (Interactor?) -> V) -> some View
    {
        modifier(CustomModalSheetModifier(interactor: interactor, viewFactory: view))
    }

}

struct CustomModalSheetModifier<Interactor: AnyObject, V: View>: ViewModifier {
    @State private var showSheet: Bool = false
    @Binding @EquatableStore var interactor: Interactor?

    let viewFactory: (Interactor?) -> V

    func body(content: Content) -> some View {
        content
            .onChange(of: $interactor.wrappedValue) { value in
                showSheet = (value.wrappedValue != nil)
            }
            .sheet(
                isPresented: $showSheet,
                onDismiss: { interactor = nil },
                content: { viewFactory(interactor) }
            )
    }
}

@propertyWrapper
struct EquatableStore<Value: AnyObject>: Equatable {
    var wrappedValue: Value?

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs.wrappedValue, rhs.wrappedValue) {
        case let (lValue?, rValue?): lValue === rValue
        case (nil, nil): true
        default: false
        }
    }
}
