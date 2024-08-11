//
//  Button++.swift
//  Text Capture
//
//  Created by Aue Angpanitcharoen on 10/08/2024.
//

#if os(macOS)
import AppKit
import SwiftUI
import Carbon.HIToolbox

class KeyboardShortcutsValue : ObservableObject {
	@Published var shortcut: KeyboardShortcuts.Shortcut?
	@Published var name: KeyboardShortcuts.Name
	
	init(_ name: KeyboardShortcuts.Name) {
		self.name = name
		self.shortcut = KeyboardShortcuts.getShortcut(for: name)
	}
	
	
}

struct UpdateKeyboardShortcut: ViewModifier {
	@ObservedObject var state: KeyboardShortcutsValue
	
	init(_ shortcutName: KeyboardShortcuts.Name) {
		self.state = KeyboardShortcutsValue(shortcutName)
		setupNotificationCenter()
	}
	
	func setupNotificationCenter() {
		NotificationCenter.default.addObserver(forName: .shortcutByNameDidChange, object: nil, queue: nil) { notification in
			guard
				let nameInNotification = notification.userInfo?["name"] as? KeyboardShortcuts.Name,
				nameInNotification == state.name
			else {
				return
			}

			let current = KeyboardShortcuts.getShortcut(for: state.name)
			state.shortcut = current
		}
	}
	
	func body(content: Content) -> some View {
		content.keyboardShortcutOnce(for: state.name)
	}
	
}

extension View {
	@MainActor
	public func keyboardShortcut(for name: KeyboardShortcuts.Name) -> some View {
		modifier(UpdateKeyboardShortcut(name))
	}
	
	@MainActor
	public func keyboardShortcutOnce(for name: KeyboardShortcuts.Name) -> some View {
		let shortcut = KeyboardShortcuts.Shortcut(name: name)
		return keyboardShortcutOnce(shortcut!)
	}
	
	@MainActor
	@_disfavoredOverload
	public func keyboardShortcutOnce(_ shortcut: KeyboardShortcuts.Shortcut) -> some View {
		return keyboardShortcut(KeyEquivalent(Character(shortcut.keyEquivalent)), modifiers: SwiftUICore.EventModifiers(shortcut.modifiers))
	}
}


extension SwiftUICore.EventModifiers {
	init(_ modifierFlags: NSEvent.ModifierFlags) {
		var modifiers: SwiftUICore.EventModifiers = []
		
		if modifierFlags.contains(.shift) {
			modifiers.insert(.shift)
		}
		if modifierFlags.contains(.control) {
			modifiers.insert(.control)
		}
		if modifierFlags.contains(.option) {
			modifiers.insert(.option)
		}
		if modifierFlags.contains(.command) {
			modifiers.insert(.command)
		}
		if modifierFlags.contains(.capsLock) {
			modifiers.insert(.capsLock)
		}
		
		self = modifiers
	}
}
#endif


