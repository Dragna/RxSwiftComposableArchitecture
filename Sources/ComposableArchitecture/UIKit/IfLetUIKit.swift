//
//  ComposableArchitecture+utils.swift
//  pureairconnect
//
//  Created by sebastien on 09/07/2020.
//  Copyright © 2020 Dragna. All rights reserved.
//

import Foundation
import RxSwift

extension Store {
  /// Subscribes to updates when a store containing optional state goes from `nil` to non-`nil` or
  /// non-`nil` to `nil`.
  ///
  /// This is useful for handling navigation in UIKit. The state for a screen that you want to
  /// navigate to can be held as an optional value in the parent, and when that value switches
  /// from `nil` to non-`nil` you want to trigger a navigation and hand the detail view a `Store`
  /// whose domain has been scoped to just that feature:
  ///
  ///     class MasterViewController: UIViewController {
  ///       let store: Store<MasterState, MasterAction>
  ///       let disposeBag = DisposeBag()
  ///       ...
  ///       func viewDidLoad() {
  ///         ...
  ///         self.store
  ///           .scope(state: \.optionalDetail, action: MasterAction.detail)
  ///           .ifLet(
  ///             then: { [weak self] detailStore in
  ///               self?.navigationController?.pushViewController(
  ///                 DetailViewController(store: detailStore),
  ///                 animated: true
  ///               )
  ///             },
  ///             else: { [weak self] in
  ///               guard let self = self else { return }
  ///               self.navigationController?.popToViewController(self, animated: true)
  ///             }
  ///           )
  ///           .disposed(by: disposeBag)
  ///       }
  ///     }
  ///
  /// - Parameters:
  ///   - unwrap: A function that is called with a store of non-optional state whenever the store's
  ///     optional state goes from `nil` to non-`nil`.
  ///   - else: A function that is called whenever the store's optional state goes from non-`nil` to
  ///     `nil`.
  /// - Returns: A Disposable associated with the underlying subscription.
  public func ifLet<Wrapped>(
    then unwrap: @escaping (Store<Wrapped, Action>) -> Void,
    else: @escaping () -> Void
  ) -> Disposable where State == Wrapped? {
    scope { (state: Observable<Wrapped?>) in
      state
        .distinctUntilChanged { ($0 != nil) == ($1 != nil) }
        .do(onNext: { if $0 == nil { `else`() } })
        .compactMap { $0 }
    }
    .subscribe(onNext: unwrap)
  }
  
  /// An overload of `ifLet(then:else:)` for the times that you do not want to handle the `else`
  /// case.
  ///
  /// - Parameter unwrap: A function that is called with a store of non-optional state whenever the
  ///   store's optional state goes from `nil` to non-`nil`.
  /// - Returns: A Disposable associated with the underlying subscription.
  public func ifLet<Wrapped>(
    then unwrap: @escaping (Store<Wrapped, Action>) -> Void
  ) -> Disposable where State == Wrapped? {
    ifLet(then: unwrap, else: {})
  }
}
