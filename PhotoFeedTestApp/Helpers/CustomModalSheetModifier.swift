//
//  CustomModalSheetModifier.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 24.06.2024.
//

import SwiftUI

protocol SheetStateProvider: AnyObject {
    func onClose()
}

extension View {

    func customSheet<StateProvider: SheetStateProvider, V: View>(
        stateProvider: Binding<EquatableStore<StateProvider>>,
        @ViewBuilder view: @escaping (StateProvider?) -> V) -> some View
    {
        modifier(CustomModalSheetModifier(stateProvider: stateProvider, viewFactory: view))
    }

}

struct CustomModalSheetModifier<StateProvider: SheetStateProvider, V: View>: ViewModifier {
    @State private var showSheet: Bool = false
    @Binding @EquatableStore var stateProvider: StateProvider?

    let viewFactory: (StateProvider?) -> V

    func body(content: Content) -> some View {
        content
            .onChange(of: $stateProvider.wrappedValue) { value in
                showSheet = (value.wrappedValue != nil)
            }
            .sheet(
                isPresented: $showSheet,
                onDismiss: {
                    stateProvider?.onClose()
                    stateProvider = nil
                },
                content: { viewFactory(stateProvider) }
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
