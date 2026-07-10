//
//  AutofillHighlight.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/10/26.
//

import SwiftUI

// MARK: - AutofillHighlight

/// Highlights a field whose value was just filled in programmatically: the text
/// fades in tinted with the accent color, holds briefly, then the accent bleeds
/// away to the normal system text color.
///
/// Attach via `.modifier(AutofillHighlight(active:))`, passing a flag that flips
/// to `true` at the moment of autofill (it only needs to transition once).
///
/// Two independent animations run:
/// - **opacity** — a plain fade-in. Opacity is natively animatable on any view,
///   so a normal `withAnimation` is enough; nothing special required.
/// - **color** — accent → label. This is the hard part and is delegated to
///   ``MixedForeground`` below. See its docs for *why* it can't just be a
///   `withAnimation` on `.foregroundStyle`.
struct AutofillHighlight: ViewModifier {
    /// Flips to `true` the instant the field is autofilled. Drives the effect.
    let active: Bool

    @State private var opacity: Double = 1
    /// 1 = fully accent, 0 = normal text color. Handed to ``MixedForeground``.
    @State private var accentAmount: Double = 0

    func body(content: Content) -> some View {
        content
            .modifier(MixedForeground(amount: accentAmount))
            .opacity(opacity)
            .onChange(of: active) { _, on in
                guard on else { return }

                // Set the "start" state *without* animation, in this render tick:
                // invisible and fully accent.
                //
                // Why a separate tick from the animation below? If we set the
                // start value and the end value in the same synchronous scope,
                // SwiftUI coalesces them and only ever commits the final value —
                // the start frame never renders, so there's nothing to animate
                // from. Kicking the animations off in a `Task` defers them to a
                // later tick, after this start state has been committed once.
                opacity = 0
                accentAmount = 1

                Task {
                    // Fade the accent-tinted text in.
                    withAnimation(.easeIn(duration: 0.35)) { opacity = 1 }
                    // Hold at full accent for a beat.
                    try? await Task.sleep(for: .seconds(0.45))
                    // Bleed the accent out to the normal text color.
                    withAnimation(.easeOut(duration: 0.6)) { accentAmount = 0 }
                }
            }
    }
}

// MARK: - MixedForeground

/// Sets the foreground color to a blend of `Color(.label)` (at `amount == 0`) and
/// the accent color (at `amount == 1`), recomputing a *concrete* color on every
/// animation frame.
///
/// ## Why this exists — the `TextField` color problem
///
/// You'd expect `withAnimation { color = ... }` on `.foregroundStyle` to fade the
/// text color. It doesn't on a `TextField`: `TextField` is backed by UIKit's
/// `UITextField`, and SwiftUI applies the *final* text color to it in one step
/// rather than tweening through intermediate colors. The result is a hard snap.
///
/// ## How `Animatable` fixes it
///
/// `Animatable` is the protocol SwiftUI uses to interpolate a view/modifier over
/// the course of an animation. Its single requirement is `animatableData`: a
/// value conforming to `VectorArithmetic` (here, `Double`) that SwiftUI can do
/// math on — add, subtract, scale.
///
/// When an animation changes `amount` from 1 → 0, SwiftUI doesn't just jump. It
/// reads the old `animatableData` (1) and the new one (0), then for each frame of
/// the animation it computes an interpolated value (…0.9, 0.8, …) **and re-invokes
/// `body` with a fresh copy of the modifier carrying that interpolated value.**
///
/// That's the key difference from a plain `@State` change: a bare animated
/// `Double` only tells SwiftUI the start and end; conforming to `Animatable` is
/// what makes `body` actually run ~60×/sec with the in-between values.
///
/// So every frame we build a brand-new *concrete* `Color` via `Color.mix` and
/// hand it to `.foregroundStyle`. The `TextField` receives a stream of ~60
/// discrete colors, and applying each one in turn *looks* like a smooth fade —
/// we're doing the interpolation ourselves instead of relying on SwiftUI to tween
/// the color for a control that won't.
///
/// ## The `nonisolated` requirement
///
/// `ViewModifier` is `@MainActor`-isolated, so by default `amount` and its
/// accessors are too. But `Animatable.animatableData` is a `nonisolated`
/// requirement — SwiftUI's animation machinery reads and writes it off the main
/// actor. Implementing it as `@MainActor` fails to satisfy the protocol and Swift
/// 6 flags a possible data race. Marking it `nonisolated` matches the requirement.
/// It's safe because `amount` is a `Sendable` `Double` stored on a value type:
/// there's no shared mutable reference to race on.
private struct MixedForeground: ViewModifier, Animatable {
    var amount: Double

    nonisolated var animatableData: Double {
        get { amount }
        set { amount = newValue }
    }

    func body(content: Content) -> some View {
        content.foregroundStyle(Color(.label).mix(with: BrandColors.accent, by: amount))
    }
}
