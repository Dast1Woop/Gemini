import UIKit
import Gemini

enum CustomAnimationType {
    case custom1
    case custom2

    fileprivate func layout(withParentView parentView: UIView) -> UICollectionViewFlowLayout {
        switch self {
        case .custom1:
            let kSectionMargin = 60.0
            let layout = UICollectionViewPagingFlowLayout()
            layout.itemSize = CGSize(width: parentView.bounds.width - kSectionMargin*2, height: 150)
            
            //保证collectionV最左边和最右边间距都是 kSectionMargin，此时设置itemSize为俯视图宽-kSectionMargin*2（保证拖动cell居中时，cell左右边缘距离屏幕都是kSectionMargin），可以保证首个cell居中，后面cell水平间距通过minimumLineSpacing设置(必须<kSectionMargin 才能看到左右cell边缘)
            layout.sectionInset = UIEdgeInsets(top: 0, left: kSectionMargin, bottom: 0, right: kSectionMargin)
            
            /** For a horizontally scrolling grid, this value represents the minimum spacing between successive columns. This spacing is not applied to the space between the header and the first line or between the last line and the footer.
             The default value of this property is 10.0.
             */
            layout.minimumLineSpacing = 20
            layout.scrollDirection = .horizontal
            return layout

        case .custom2:
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: 150, height: 150)
            layout.sectionInset = UIEdgeInsets(top: 15,
                                               left: (parentView.bounds.width - 150) / 2,
                                               bottom: 15,
                                               right: (parentView.bounds.width - 150) / 2)
            layout.minimumLineSpacing = 15
            layout.scrollDirection = .vertical
            return layout
        }
    }
}

final class CustomAnimationViewController: UIViewController {
    @IBOutlet private weak var collectionView: GeminiCollectionView! {
        didSet {
            let nib = UINib(nibName: cellIdentifier, bundle: nil)
            collectionView.register(nib, forCellWithReuseIdentifier: cellIdentifier)
            collectionView.delegate   = self
            collectionView.dataSource = self

            if #available(iOS 11.0, *) {
                collectionView.contentInsetAdjustmentBehavior = .never
            }
        }
    }

    private let cellIdentifier = String(describing: ImageCollectionViewCell.self)
    private let images = Resource.image.images
    private var animationType = CustomAnimationType.custom2

    static func make(animationType: CustomAnimationType) -> CustomAnimationViewController {
        let storyboard = UIStoryboard(name: "CustomAnimationViewController", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CustomAnimationViewController") as! CustomAnimationViewController
        viewController.animationType = animationType
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(toggleNavigationBarHidden(_:)))
        gesture.cancelsTouchesInView = false
        view.addGestureRecognizer(gesture)

        switch animationType {
        case .custom1:
            collectionView.collectionViewLayout = animationType.layout(withParentView: view)
            collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
            collectionView.gemini
                .customAnimation()
                .translation(x:0, y: 0, z:0)//y:当前cell在y坐标轴上比左右cell高出多少
                .rotationAngle(x:0, y: 0, z:0)//y:当前cell在y坐标轴上旋转角度
                .scale(x: 1, y: 0.9, z: 1)//y:当前cell在移到旁边时缩放比
                .ease(.easeOutExpo)
                .shadowEffect(.fadeIn)
                .maxShadowAlpha(0.1)//y:当前cell在移到旁边时黑色遮罩的不透明度

        case .custom2:
            collectionView.collectionViewLayout = animationType.layout(withParentView: view)
            collectionView.gemini
                .customAnimation()
                .backgroundColor(startColor: UIColor(red: 38 / 255, green: 194 / 255, blue: 129 / 255, alpha: 1),
                                 endColor: UIColor(red: 89 / 255, green: 171 / 255, blue: 227 / 255, alpha: 1))
                .ease(.easeOutSine)
                .cornerRadius(75)
        }
    }

    @objc private func toggleNavigationBarHidden(_ gestureRecognizer: UITapGestureRecognizer) {
        let isNavigationBarHidden = navigationController?.isNavigationBarHidden ?? true
        navigationController?.setNavigationBarHidden(!isNavigationBarHidden, animated: true)
    }
}

// MARK: - UIScrollViewDelegate

extension CustomAnimationViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionView.animateVisibleCells()
    }
}

// MARK: - UICollectionViewDelegate

extension CustomAnimationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? GeminiCell {
            self.collectionView.animateCell(cell)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension CustomAnimationViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ImageCollectionViewCell

        if animationType == .custom1 {
            cell.configure(with: images[indexPath.row])
        }

        self.collectionView.animateCell(cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(#function, indexPath)
    }
}
