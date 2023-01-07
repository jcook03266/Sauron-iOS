//
//  PortfolioDataProvider.swift
//  Sauron
//
//  Created by Justin Cook on 1/5/23.
//

import Foundation
import SwiftUI
import CoreData

class PortfolioDataProvider: DataProviderProtocol {
    // MARK: - Published
    @Published var savedEntities: [PortfolioCoinEntity] = []
    
    // MARK: - Singleton
    /// Reinstantiating this object is expensive due to loading persistent stores from the disk, thus it's faster to share the spun up stores with whatever instance presently requires it across the app
    static let shared: PortfolioDataProvider = .init()
    
    // MARK: - Core data properties
    private let container: NSPersistentContainer,
                containerName: String = "PortfolioContainer",
                entityName: String = "PortfolioCoinEntity",
                entityType = PortfolioCoinEntity.self
    
    private var managedObjectContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    private init() {
        container = NSPersistentContainer(name: containerName)
        loadPersistentStores()
    }
    
    // MARK: - Public Interface
    func setup() {}
    func load() {}
    
    /// Saves the current context and reloads all saved entities for a completely synced persistent store and entity store
    func reload() {
        updateWithChanges()
    }
    
    /// Update a coin already present in the portfolio with the given
    func updatePortfolio(with coin: CoinModel,
                         using properties: [Portfolio.EntityCodingKeys : Any] = [:]) {
        let doesExistTuple = doesCoinExistInPortfolio(coin: coin)
        
        guard doesExistTuple.0, let savedEntity = doesExistTuple.1 else {
            add(coin: coin)
            return
        }
        
        updateEntity(savedEntity, with: properties)
    }
    
    func removeCoinFromPortfolio(coin: CoinModel) {
        let doesExistTuple = doesCoinExistInPortfolio(coin: coin)
        
        guard doesExistTuple.0, let savedEntity = doesExistTuple.1 else { return }
        
        delete(entity: savedEntity)
    }
    
    func removeAllCoins() {
        for entity in savedEntities {
            delete(entity: entity)
        }
        
        updateWithChanges()
    }
    
    func doesCoinExistInPortfolio(coin: CoinModel) -> (Bool, PortfolioCoinEntity?) {
        let savedEntity = savedEntities.first { $0.coinID == coin.id }
        
        return (savedEntity != nil, savedEntity)
    }
    
    // MARK: - Privatized Methods
    private func add(coin: CoinModel) {
        let entity = PortfolioCoinEntity(context: managedObjectContext)
        
        entity.coinID = coin.id // Key used to fetch the full coin data from the data store
        entity.addDate = .now // When this coin was added to the user's portfolio
        entity.lastUpdate = .now
        entity.totalViews = 0
        
        guard !doesEntityExistInContainer(entity: entity) else { return }
        savedEntities.append(entity)
        
        save()
    }
    
    private func delete(entity: PortfolioCoinEntity) {
        managedObjectContext.delete(entity)
        
        guard doesEntityExistInContainer(entity: entity) else { return }
        savedEntities.removeAll { $0 == entity }
        
        save()
    }
    
    private func doesEntityExistInContainer(entity: PortfolioCoinEntity) -> Bool {
        return savedEntities.first { $0.id == entity.id } != nil
    }
    
    private func updateEntity(_ entity: PortfolioCoinEntity,
                              with properties: [Portfolio.EntityCodingKeys : Any] = [:]) {
        
        for key in Portfolio.EntityCodingKeys.allCases {
            switch key {
            case .coinID:
                break
            case .lastUpdate:
                guard let lastUpdate = properties[key],
                      let lastUpdate = lastUpdate as? Date
                else { break }
                
                entity.lastUpdate = lastUpdate
            case .totalViews:
                guard let totalViews = properties[key],
                      let totalViews = totalViews as? Int64
                else { break }
                
                entity.totalViews = totalViews
            case .addDate:
                break
            }
        }
    }
    
    private func loadPersistentStores() {
        container.loadPersistentStores { [weak self] (_, error) in
            if let self = self,
               let error = error {
                ErrorCodeDispatcher.CoreDataErrors.printErrorCode(for: .containerPersistenStoreLoadFailure(containerName: self.containerName,
                                                                                                           localErrorDescription: error.localizedDescription))
            }
        }
        
        managedObjectContext.automaticallyMergesChangesFromParent = true
        fetchEntities()
    }
    
    private func fetchEntities() {
        let request = NSFetchRequest<PortfolioCoinEntity>(entityName: entityName)
        do {
            savedEntities = try managedObjectContext.fetch(request)
        } catch let error {
            ErrorCodeDispatcher.CoreDataErrors.printErrorCode(for: .entitySaveError(entityName: entityName,
                                                                                    localErrorDescription: error.localizedDescription))
        }
    }
    
    private func save() {
        do {
            try managedObjectContext.save()
        } catch let error {
            ErrorCodeDispatcher.CoreDataErrors.printErrorCode(for: .entitySaveError(entityName: entityName,
                                                                                    localErrorDescription: error.localizedDescription))
        }
    }
    
    /// Updates the persistent store with the latest data from the context given some arbitrary changes saved to the past context
    private func updateWithChanges() {
        save()
        fetchEntities()
    }
}
