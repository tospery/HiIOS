import UIKit

/// The `PagingViewControllerDataSource` protocol is used to provide
/// the `PagingItem` you want to display and which view controller it
/// is associated with. Using this data sources requires you to have a
/// fixed number of view controllers.
///
/// In order for these methods to be called, you first need to set the
/// initial `PagingItem` by calling `select(pagingItem:)` on
/// `OldPagingViewController`.
public protocol PagingViewControllerDataSource: AnyObject {
    /// Return the total number of view controllers
    ///
    /// - Parameter pagingViewController: The `OldPagingViewController`
    /// instance
    /// - Returns: The number of view controllers
    func numberOfViewControllers(in pagingViewController: OldPagingViewController) -> Int

    /// Return the view controller accociated with a given index. This
    /// method is only called for the currently selected `PagingItem`,
    /// and its two possible siblings.
    ///
    /// - Parameter pagingViewController: The `OldPagingViewController`
    /// instance
    /// - Parameter index: The index of a given `PagingItem`
    /// - Returns: The view controller for the given index
    func pagingViewController(_: OldPagingViewController, viewControllerAt index: Int) -> UIViewController

    /// Return the `PagingItem` instance for a given index
    ///
    /// - Parameter pagingViewController: The `OldPagingViewController`
    /// instance
    /// - Returns: The `PagingItem` instance
    func pagingViewController(_: OldPagingViewController, pagingItemAt index: Int) -> PagingItem
}
