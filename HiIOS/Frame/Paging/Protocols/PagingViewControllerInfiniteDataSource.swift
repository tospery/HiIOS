import UIKit

/// The `PagingViewControllerInfiniteDataSource` protocol is used to
/// provide the `PagingItem` you want to display and which view
/// controller it is associated with.
///
/// In order for these methods to be called, you first need to set
/// the initial `PagingItem` by calling `select(pagingItem:)` on
/// `OldPagingViewController`.
public protocol PagingViewControllerInfiniteDataSource: AnyObject {
    /// Return the view controller accociated with a `PagingItem`. This
    /// method is only called for the currently selected `PagingItem`,
    /// and its two possible siblings.
    ///
    /// - Parameter pagingViewController: The `OldPagingViewController`
    /// instance
    /// - Parameter viewControllerForPagingItem: A `PagingItem` instance
    /// - Returns: The view controller for the `PagingItem` instance
    func pagingViewController(_: OldPagingViewController, viewControllerFor pagingItem: PagingItem) -> UIViewController

    /// The `PagingItem` that comes before a given `PagingItem`
    ///
    /// - Parameter pagingViewController: The `OldPagingViewController`
    /// instance
    /// - Parameter pagingItemBeforePagingItem: A `PagingItem` instance
    /// - Returns: The `PagingItem` that appears before the given
    /// `PagingItem`, or `nil` to indicate that no more progress can be
    /// made in that direction.
    func pagingViewController(_: OldPagingViewController, itemBefore pagingItem: PagingItem) -> PagingItem?

    /// The `PagingItem` that comes after a given `PagingItem`
    ///
    /// - Parameter pagingViewController: The `OldPagingViewController`
    /// instance
    /// - Parameter pagingItemAfterPagingItem: A `PagingItem` instance
    /// - Returns: The `PagingItem` that appears after the given
    /// `PagingItem`, or `nil` to indicate that no more progress can be
    /// made in that direction.
    func pagingViewController(_: OldPagingViewController, itemAfter pagingItem: PagingItem) -> PagingItem?
}
