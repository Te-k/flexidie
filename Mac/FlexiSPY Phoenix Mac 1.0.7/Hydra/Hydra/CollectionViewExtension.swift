//
//  CollectionViewExtension.swift
//  Hydra
//
//  Created by Chanin Nokpet on 1/11/17.
//  Copyright © 2017 Makara Khloth. All rights reserved.
//

import Foundation

extension UICollectionView {
    func reloadWithFadeAnimation(section: Int) {
        self.performBatchUpdates({
            self.reloadSections(IndexSet(integer: section))
        }){ completed in
        }
    }
}
