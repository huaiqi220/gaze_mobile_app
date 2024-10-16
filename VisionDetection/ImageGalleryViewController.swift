import UIKit

class ImageGalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var folders: [String] = []  // 保存子文件夹名称
    var images: [UIImage] = []
    var imageNames: [String] = []
    var currentDirectory: URL?  // 当前展示的文件夹路径
    var inFolderMode = true     // 当前是否在文件夹模式

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "校准图像"

        // 加载文件夹
        loadFolders()

        // 创建集合视图
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        view.addSubview(collectionView)
        
    }

    // 加载子文件夹
    func loadFolders() {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("无法访问文档目录")
            return
        }

        let imagesDirectory = documentsDirectory.appendingPathComponent("images/cali")
        do {
            let directoryContents = try fileManager.contentsOfDirectory(atPath: imagesDirectory.path)
            for content in directoryContents {
                let fullPath = imagesDirectory.appendingPathComponent(content)
                var isDir: ObjCBool = false
                if fileManager.fileExists(atPath: fullPath.path, isDirectory: &isDir), isDir.boolValue {
                    folders.append(content) // 只保存子文件夹名称
                }
            }
        } catch {
            print("加载文件夹失败: \(error)")
        }
    }

    // 加载指定文件夹下的图片
    func loadImages(fromFolder folderName: String) {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("无法访问文档目录")
            return
        }
        
        let selectedFolder = documentsDirectory.appendingPathComponent("images/cali/\(folderName)")
        currentDirectory = selectedFolder
        
        do {
            let fileNames = try fileManager.contentsOfDirectory(atPath: selectedFolder.path)
            images = []
            imageNames = []
            for fileName in fileNames {
                let fileURL = selectedFolder.appendingPathComponent(fileName)
                if let image = UIImage(contentsOfFile: fileURL.path) {
                    images.append(image)
                    imageNames.append(fileName)
                }
            }
        } catch {
            print("加载图像失败: \(error)")
        }
    }
    
    // UICollectionViewDataSource 方法
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inFolderMode ? folders.count : images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        // 移除旧的子视图
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        if inFolderMode {
            // 文件夹模式下展示文件夹图标和名称
            let folderImageView = UIImageView(image: UIImage(systemName: "folder.fill")) // 使用系统图标
            folderImageView.tintColor = .systemBlue
            folderImageView.contentMode = .scaleAspectFit
            folderImageView.frame = CGRect(x: 0, y: 0, width: cell.contentView.bounds.width, height: cell.contentView.bounds.height * 0.6)
            cell.contentView.addSubview(folderImageView)
            
            let label = UILabel(frame: CGRect(x: 0, y: cell.contentView.bounds.height * 0.6, width: cell.contentView.bounds.width, height: cell.contentView.bounds.height * 0.4))
            label.text = folders[indexPath.item]
            label.textAlignment = .center
            label.textColor = .black
            label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            cell.contentView.addSubview(label)
        } else {
            // 图片模式下展示图片
            let imageView = UIImageView(image: images[indexPath.item])
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.frame = cell.contentView.bounds
            cell.contentView.addSubview(imageView)
        }
        
        return cell
    }

    // UICollectionViewDelegate 方法
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if inFolderMode {
            // 点击文件夹，加载该文件夹内的图片
            let selectedFolder = folders[indexPath.item]
            loadImages(fromFolder: selectedFolder)
            inFolderMode = false
            collectionView.reloadData()
        }
    }

    // UICollectionViewDelegateFlowLayout 方法
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.bounds.width - 20) / 3, height: (view.bounds.width - 20) / 3)
    }
}
