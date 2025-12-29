//
//  DummyData.swift
//  PillCounter
//
//  Created by HC on 29/12/25.
//

import CoreData
import SwiftUI

struct PreviewDataHelper {

    static let shared = PreviewDataHelper()
    let container: NSPersistentContainer

    init() {
        // Use your actual .xcdatamodeld file name here. Assuming "PillCounter"
        container = NSPersistentContainer(name: "PillCounter")

        // Point to /dev/null to make it purely in-memory (no file saved)
        container.persistentStoreDescriptions.first!.url = URL(
            fileURLWithPath: "/dev/null")

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
    }

    func createDummyTransaction() -> PillCountTransactionEntity {
        let context = container.viewContext

        // 1. Create Dummy Drug
        let drug = DrugMasterEntity(context: context)
        drug.drug_name = "Amoxicillin 500mg"
        drug.ndc = "67877-111-01"
        drug.drug_id = 101

        // 2. Create Transaction
        let txn = PillCountTransactionEntity(context: context)
        txn.txn_id = 12345
        txn.created_at = Int64(Date().timeIntervalSince1970 * 1000)
        txn.target_count = 100
        txn.status = "Pending"
        txn.note = "Patient waiting in lobby. Count carefully."
        txn.drug = drug

        // 3. Create Transaction Details (Batches)
        // Batch 1
        let detail1 = PillCountTransactionDetailsEntity(context: context)
        detail1.txn_details_id = 1
        detail1.pill_count = 45
        detail1.created_at = Int64(Date().timeIntervalSince1970 * 1000)
        // Note: In a real app, image_path is a file URL string.
        // For preview, we handle nil images or mock paths in the View logic.
        detail1.image_path = nil
        detail1.pillCountTransaction = txn

        // Batch 2
        let detail2 = PillCountTransactionDetailsEntity(context: context)
        detail2.txn_details_id = 2
        detail2.pill_count = 10
        detail2.created_at = Int64(
            Date().addingTimeInterval(60).timeIntervalSince1970 * 1000)
        detail2.pillCountTransaction = txn

        // Batch 3
        let detail3 = PillCountTransactionDetailsEntity(context: context)
        detail3.txn_details_id = 3
        detail3.pill_count = 14
        detail3.created_at = Int64(
            Date().addingTimeInterval(120).timeIntervalSince1970 * 1000
        )
        detail3.pillCountTransaction = txn

        // Batch 4
        let detail4 = PillCountTransactionDetailsEntity(context: context)
        detail4.txn_details_id = 4
        detail4.pill_count = 8
        detail4.created_at = Int64(
            Date().addingTimeInterval(180).timeIntervalSince1970 * 1000
        )
        detail4.pillCountTransaction = txn

        // Batch 5
        let detail5 = PillCountTransactionDetailsEntity(context: context)
        detail5.txn_details_id = 5
        detail5.pill_count = 20
        detail5.created_at = Int64(
            Date().addingTimeInterval(240).timeIntervalSince1970 * 1000
        )
        detail5.pillCountTransaction = txn

        // 4. Link relationships
        txn.addToPillCountTransactionDetails([detail1, detail2])

        return txn
    }
}
