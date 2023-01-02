//
//  BatchChoiceView.swift
//  Ferrite
//
//  Created by Brian Dashore on 7/24/22.
//

import SwiftUI

struct BatchChoiceView: View {
    @EnvironmentObject var debridManager: DebridManager
    @EnvironmentObject var scrapingModel: ScrapingViewModel
    @EnvironmentObject var navModel: NavigationViewModel

    let backgroundContext = PersistenceController.shared.backgroundContext

    var body: some View {
        NavView {
            List {
                switch debridManager.selectedDebridType {
                case .realDebrid:
                    ForEach(debridManager.selectedRealDebridItem?.files ?? [], id: \.self) { file in
                        Button(file.name) {
                            debridManager.selectedRealDebridFile = file

                            queueCommonDownload(fileName: file.name)
                        }
                    }
                case .allDebrid:
                    ForEach(debridManager.selectedAllDebridItem?.files ?? [], id: \.self) { file in
                        Button(file.fileName) {
                            debridManager.selectedAllDebridFile = file

                            queueCommonDownload(fileName: file.fileName)
                        }
                    }
                case .premiumize:
                    ForEach(debridManager.selectedPremiumizeItem?.files ?? [], id: \.self) { file in
                        Button(file.name) {
                            debridManager.selectedPremiumizeFile = file

                            queueCommonDownload(fileName: file.name)
                        }
                    }
                case .none:
                    EmptyView()
                }
            }
            .backport.tint(.primary)
            .listStyle(.insetGrouped)
            .inlinedList()
            .navigationTitle("Select a file")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        navModel.currentChoiceSheet = nil

                        Task {
                            try? await Task.sleep(seconds: 1)

                            debridManager.clearSelectedDebridItems()
                        }
                    }
                }
            }
        }
    }

    // Common function to communicate betwen VMs and queue/display a download
    func queueCommonDownload(fileName: String) {
        debridManager.currentDebridTask = Task {
            await debridManager.fetchDebridDownload(magnetLink: navModel.resultFromCloud ? nil : navModel.selectedMagnetLink)

            if !debridManager.downloadUrl.isEmpty {
                try? await Task.sleep(seconds: 1)
                navModel.selectedBatchTitle = fileName

                if var selectedHistoryInfo = navModel.selectedHistoryInfo {
                    selectedHistoryInfo.url = debridManager.downloadUrl
                    PersistenceController.shared.createHistory(selectedHistoryInfo)
                }

                navModel.runDebridAction(urlString: debridManager.downloadUrl)
            }

            debridManager.clearSelectedDebridItems()
        }

        navModel.currentChoiceSheet = nil
    }
}

struct BatchChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        BatchChoiceView()
    }
}