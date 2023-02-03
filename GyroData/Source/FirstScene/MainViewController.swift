//
//  MainViewController.swift
//  GyroData
//
//  Created by inho on 2023/02/03.
//

import UIKit

class MainViewController: UIViewController {
    typealias DataSource = UITableViewDiffableDataSource<Section, MotionData>
    
    enum Section {
        case main
    }
    
    private let mainTableView: UITableView = {
        let tableView = UITableView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(MotionDataCell.self, forCellReuseIdentifier: MotionDataCell.identifier)
        tableView.separatorStyle = .none
        
        return tableView
    }()
    private var mainDataSource: DataSource?
    private var mainViewModel: MainViewModel = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureView()
        configureDataSource()
        bindViewModel()
        configureSnapShot(motionDatas: mainViewModel.motionDatas)
        mainTableView.delegate = self
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "목록"
        navigationItem.rightBarButtonItem = .init(
            title: "측정",
            style: .plain,
            target: self,
            action: nil
        )
    }
    
    private func configureView() {
        view.addSubview(mainTableView)
        
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            mainTableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            mainTableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            mainTableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            mainTableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        mainViewModel.bindData { [weak self] motionDatas in
            self?.configureSnapShot(motionDatas: motionDatas)
        }
    }
}

extension MainViewController {
    private func configureDataSource() {
        mainDataSource = DataSource(tableView: mainTableView) { tableView, indexPath, data in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: MotionDataCell.identifier,
                for: indexPath
            ) as? MotionDataCell else {
                return UITableViewCell()
            }
            
            let cellViewModel = MotionCellViewModel(motionData: data)
            
            cell.configureViewModel(cellViewModel)
            cellViewModel.convertCellData()
            
            return cell
        }
    }
    
    private func configureSnapShot(motionDatas: [MotionData]) {
        var snapShot = NSDiffableDataSourceSnapshot<Section, MotionData>()
        
        snapShot.appendSections([.main])
        snapShot.appendItems(motionDatas)
        
        mainDataSource?.apply(snapShot, animatingDifferences: true)
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let playButton = UIContextualAction(style: .normal, title: "Play") { _, _, _ in
            print("play button pressed")
        }
        let deleteButton = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            guard let cell = tableView.cellForRow(at: indexPath) as? MotionDataCell,
                  let viewModel = cell.viewModel
            else {
                return
            }
            
            print("\(viewModel)해당 셀이 삭제될 예정입니다.")
        }
        
        playButton.backgroundColor = .systemGreen
        
        return UISwipeActionsConfiguration(actions: [deleteButton, playButton])
    }
}