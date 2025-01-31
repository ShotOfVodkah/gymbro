//
//  DragDropDelegate.swift
//  GymBro
//
//  Created by Stepan Polyakov on 01.02.2025.
//

import SwiftUI

struct DragDropDelegate: DropDelegate {
    
    let destinationItem: Exercise
    @Binding var selected: [Exercise]
    @Binding var draggedItem: Exercise?
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        if let draggedItem {
            let fromIndex = selected.firstIndex(of: draggedItem)
            if let fromIndex {
                let toIndex = selected.firstIndex(of: destinationItem)
                if let toIndex, fromIndex != toIndex {
                    withAnimation {
                        self.selected.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: (toIndex > fromIndex ? (toIndex + 1) : toIndex))
                    }
                }
            }
        }
    }
}
