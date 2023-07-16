//
//  PostsCollectionViewController.swift
//  techSocialMediaApp
//
//  Created by David Granger on 6/27/23.
//

import UIKit
import Combine

class PostsCollectionViewController: UICollectionViewController {
    
    /*func modalDismissed() {
        whichPage = 0
        fetchPosts()
        reloadSnapshot()
    }*/
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewPostSegue" {
            let modalVC = segue.destination as! NewPostViewController
            //modalVC.delegate = self
        }
    }
    
    @IBOutlet weak var layoutButton: UIBarButtonItem!
    
    @IBSegueAction func postTapped(_ coder: NSCoder, sender: Any?) -> CommentsTableViewController? {
        guard let cell = sender as? PostCollectionViewCell,
              let indexPath = collectionView.indexPath(for: cell) else {
            return CommentsTableViewController(coder: coder)
        }
        
        let commentsTableViewController = CommentsTableViewController(selectedPost: posts[indexPath.row], coder: coder)
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        return commentsTableViewController
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: buttonPosition)
        guard let index = indexPath else { return }
        let cell = collectionView.cellForItem(at: index) as! PostCollectionViewCell
        guard var item = cell.item else { return }
        item.userLiked.toggle()
        let imageName = item.userLiked ? "hand.thumbsup.fill" : "hand.thumbsup"
        if item.userLiked {
            UIButton.animate(withDuration: 0.2, animations: {
                let scaleTransform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                let rotationTransform = CGAffineTransform(rotationAngle: -(.pi / 7))
                let translationTransform = CGAffineTransform(translationX: 0, y: -5)
                let combinedTransform = scaleTransform.concatenating(rotationTransform).concatenating(translationTransform)
                cell.likeButton.transform = combinedTransform
            }, completion: { _ in
                UIButton.animate(withDuration: 0.2, animations: {
                    cell.likeButton.transform = CGAffineTransform.identity
                })
            })
        }
        cell.likeButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        Task {
            do {
                let updatedItem = try await APIController.shared.updateLikeOrUnlike(for: item)
                cell.item = updatedItem
                cell.configure(item: updatedItem)
                posts[index.row].likes = updatedItem.likes
                posts[index.row].userLiked = updatedItem.userLiked
            } catch let error {
                print("Error executing task. \(error)")
            }
        }
    }
    
    @IBAction func layoutTapped(_ sender: Any) {
        switch activeLayout {
        case .grid:
            activeLayout = .column
        case .column:
            activeLayout = .grid
        }
    }
    
    enum Layout: Int, CaseIterable {
        case grid
        case column
    }
    
    var layout: [Layout: UICollectionViewLayout] = [:]
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, Post>!
    @Published private var posts: [Post] = []
    private var cancellables = Set<AnyCancellable>()
    private var isPaginating = false
    var whichPage: Int = 0
    let defaults = UserDefaults.standard
    var whichLayoutUserChose: Layout = .grid
    
    var activeLayout: Layout = .grid {
        didSet {
            if let layout = layout[activeLayout] {
                reloadSnapshot()
                
                collectionView.setCollectionViewLayout(layout,
                   animated: true) { (_) in
                    switch self.activeLayout {
                    case .grid:
                        self.layoutButton.image = UIImage(systemName:
                           "rectangle.grid.1x2")
                    case .column:
                        self.layoutButton.image = UIImage(systemName:
                           "square.grid.2x2")
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundView = UIImageView(image: UIImage(named: "paper"))
        
        retrieveUserDefaults()
        configureActiveLayout()
        
        //These functions are in a specific order to allow the collection view to paginate correctly.
        fetchPosts()
        observePosts()
        setupDataSource()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        activeLayout = whichLayoutUserChose
        if whichLayoutUserChose == .grid {
            self.layoutButton.image = UIImage(systemName: "rectangle.grid.1x2")
        } else {
            self.layoutButton.image = UIImage(systemName: "square.grid.2x2")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        whichLayoutUserChose = activeLayout
        setUserDefaults()
    }
    
    func retrieveUserDefaults() {
        if let isGrid = defaults.object(forKey: "PostsLayoutIsGrid") {
            whichLayoutUserChose = isGrid as! Bool ? .grid : .column
        }
    }
    
    func setUserDefaults() {
        defaults.set(whichLayoutUserChose == .grid, forKey: "PostsLayoutIsGrid")
    }
    
    func configureActiveLayout() {
        layout[.grid] = generateGridLayout(15)
        layout[.column] = generateColumnLayout(12)
        if let layout = layout[activeLayout] {
            collectionView.collectionViewLayout = layout
        }
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
    
    func generateColumnLayout(_ padding: CGFloat) -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(110)), repeatingSubitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: padding, bottom: 0, trailing: padding)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: padding, leading: 0, bottom: padding, trailing: 0)
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
            guard Layout(rawValue: indexPath.section) != nil else { return UICollectionViewCell() }
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostCollectionViewCell.identifier,
                for: indexPath) as! PostCollectionViewCell
            cell.likeButton.tag = indexPath.row
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
        Task {
            let newItems = try await APIController.shared.getPosts(for: whichPage)
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

extension PostsCollectionViewController {
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
