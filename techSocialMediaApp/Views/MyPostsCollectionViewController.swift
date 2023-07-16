//
//  MyPostsCollectionViewController.swift
//  techSocialMediaApp
//
//  Created by David Granger on 6/27/23.
//

import UIKit
import Combine

class MyPostsCollectionViewController: UICollectionViewController {
    
    var userProfileIsDisplaying: UUID? = User.current?.userUUID
    
    /*@IBSegueAction func postTapped(_ coder: NSCoder, sender: Any?) -> CommentsTableViewController? {
        guard let cell = sender as? PostCollectionViewCell,
              let indexPath = collectionView.indexPath(for: cell) else {
            return CommentsTableViewController(coder: coder)
        }
        
        let commentsTableViewController = CommentsTableViewController(selectedPost: posts[indexPath.row], coder: coder)
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        return commentsTableViewController
    }*/
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, Post>!
    @Published private var posts: [Post] = []
    private var cancellables = Set<AnyCancellable>()
    private var isPaginating = false
    var whichPage: Int = 0
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundView = UIImageView(image: UIImage(named: "paper"))
        
        configureLayout()
        
        //These functions are in a specific order to allow the collection view to paginate correctly.
        fetchPosts()
        observePosts()
        setupDataSource()
        setupCollectionView()
    }
    
    func configureLayout() {
        collectionView.collectionViewLayout = generateGridLayout(CGFloat(15))
    }
    
    func generateGridLayout(_ padding: CGFloat) -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(padding)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding)
        section.interGroupSpacing = padding
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func observePosts() {
        $posts
            .filter { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                self?.reloadSnapshot()
            }.store(in: &cancellables)
    }
    
    private func setupCollectionView() {
        //You don't need to register things if they are already registered in the story board! this could cause all sorts of headaches
        collectionView.register(FooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: FooterView.identifier)
    }
    
    private func setupDataSource() {
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostCollectionViewCell.identifier,
                for: indexPath) as! PostCollectionViewCell
            cell.configure(item: item)
            return cell
        }
        
        dataSource.supplementaryViewProvider = { [unowned self] (collectionView, kind, indexPath) in
            guard let footerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionFooter,
                withReuseIdentifier: FooterView.identifier, for: indexPath) as? FooterView else { fatalError() }
            footerView.toggleLoading(isEnabled: isPaginating)
            return footerView
        }
    }
    
    private func fetchPosts(completion: (() -> Void)? = nil) {
        guard let userUUID = userProfileIsDisplaying else { return }
        Task {
            let newItems = try await APIController.shared.getUserPosts(userUUID: userUUID, pageNumber: whichPage)
            DispatchQueue.main.async { // should always have to explicitly say this for ui
                self.posts.append(contentsOf: newItems)
                completion?()
            }
        }
    }

    private func reloadSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Post>()
        snapshot.appendSections([0])
        snapshot.appendItems(posts, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension MyPostsCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == posts.count - 1 {
            print("last reached. paginate now")
            whichPage += 1
            isPaginating = true
            fetchPosts { [weak self] in
                self?.isPaginating = false
            }
        }
    }
}
