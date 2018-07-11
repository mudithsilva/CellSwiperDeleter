//
//  CellSwipeDeleter.swift
//  Purchase App
//
//  Created by Mudith Chathuranga on 7/3/18.
//  Copyright © 2018 Chathuranga. All rights reserved.
//

import Foundation
import UIKit

class CellSwipeDeleter {
    
    private var currentMenuWidth: CGFloat!
    private var menuWidth: CGFloat!
    private var cellView: UITableViewCell!
    private var cellBackgroundView: UIView!
    private var editBackgroundView: UIView!
    public var parentVC: PurchaseRequestViewController?   /// Update Parent VC
    public var index: Int!
    public var isSwipable: Bool!
    
    private enum Direction {
        case Up
        case Down
        case Left
        case Right
    }
    
    /// Change Paranet VC type
    
    init(parentVC: PurchaseRequestViewController?, cellView: UITableViewCell, cellBackgroundView: UIView, isSwipable: Bool, index: Int) {
        self.parentVC = parentVC
        self.cellView = cellView
        self.cellBackgroundView = cellBackgroundView
        self.isSwipable = isSwipable
        self.index = index
    }
    
    deinit {
        print("deinit \(cellView)")
    }
    
    public func connectGuesture() {
        let panGuesture = UIPanGestureRecognizer(target: self, action: #selector(guestureStateRecogniser(_:)))
        panGuesture.delegate = self.cellView
        self.cellBackgroundView.addGestureRecognizer(panGuesture)
        self.menuWidth = self.cellView .frame.size.width
        
        self.editBackgroundView = CellSwipeDeleterBackground.getBackgroundEditView()
        self.editBackgroundView.frame = cellBackgroundView.frame
        self.editBackgroundView.layer.cornerRadius = 10.0  /// Change Background view Radius
        self.editBackgroundView.alpha = 0
        
        self.cellView.contentView.insertSubview(self.editBackgroundView, belowSubview: self.cellBackgroundView)
        self.editBackgroundView.center = self.cellBackgroundView.center
    }
    
    @objc private func guestureStateRecogniser(_ sender: UIPanGestureRecognizer) {
        if self.isSwipable {
            let translation = sender.translation(in: self.cellView)
            let progress = self.calculateProgress(
                translationInView: translation,
                viewBounds: self.cellView.bounds,
                direction: .Left
            )
            self.mapGestureStateToInteractor(
                gestureState: sender.state,
                progress: progress,
                velocity: sender.velocity(in: self.cellView).x) {
                    //                    print(self.sideView.frame.origin.x)
            }
        }
    }
    
    private func calculateProgress(translationInView:CGPoint, viewBounds:CGRect, direction:Direction) -> CGFloat {
        let pointOnAxis:CGFloat
        let axisLength:CGFloat
        switch direction {
        case .Up, .Down:
            pointOnAxis = translationInView.y
            axisLength = viewBounds.height
        case .Left, .Right:
            pointOnAxis = translationInView.x
            axisLength = viewBounds.width
        }
        let movementOnAxis = pointOnAxis / axisLength
        let positiveMovementOnAxis:Float
        let positiveMovementOnAxisPercent:Float
        switch direction {
        case .Right, .Down: // positive
            positiveMovementOnAxis = fmaxf(Float(movementOnAxis), 0.0)
            positiveMovementOnAxisPercent = fminf(positiveMovementOnAxis, 1.0)
            return CGFloat(positiveMovementOnAxisPercent)
        case .Up, .Left: // negative
            positiveMovementOnAxis = fminf(Float(movementOnAxis), 0.0)
            positiveMovementOnAxisPercent = fmaxf(positiveMovementOnAxis, -1.0)
            return CGFloat(-positiveMovementOnAxisPercent)
        }
    }
    
    private func mapGestureStateToInteractor(gestureState:UIGestureRecognizerState, progress:CGFloat, velocity: CGFloat, triggerFunc: () -> Void) {
        switch gestureState {
        case .began:
            triggerFunc()
        case .changed:
            self.cellBackgroundView.center.x = self.cellView.frame.size.width / 2 - ((self.cellView.frame.size.width) * progress)
            self.currentMenuWidth = (self.cellView.frame.size.width) * progress
            self.editBackgroundView.alpha = 1
        case .ended:
            if velocity < CGFloat(-1000.00) {
                self.cellClose(isUserForceClose: true)
            } else {
                if self.shouldCloseCell() {
                    self.cellClose(isUserForceClose: false)
                } else {
                    self.cellOpen()
                }
            }
        default:
            break
        }
    }
    
    private func shouldCloseCell() -> Bool {
        if self.currentMenuWidth >= self.menuWidth / 2 {
            return true
        } else {
            return false
        }
    }
    
    private func cellOpen() {
        UIView.animate(withDuration: 0.3) {
            self.cellBackgroundView.center.x = self.cellView.frame.size.width / 2
            self.cellView.layoutIfNeeded()
            self.editBackgroundView.alpha = 0
        }
    }
    
    private func cellClose(isUserForceClose: Bool) {
        if isUserForceClose {
            UIView.animate(withDuration: 0.2, animations: {
                self.cellBackgroundView.center.x = -self.cellBackgroundView.frame.size.width / 2
                self.cellView.layoutIfNeeded()
            }, completion: { completed in
                self.deleteItemFromTable()
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.cellBackgroundView.center.x = -self.cellBackgroundView.frame.size.width / 2
                self.cellView.layoutIfNeeded()
            }, completion: { completed in
                self.deleteItemFromTable()
            })
        }
    }
    
    /// MARK: - Remove TableView Item
    
    private func deleteItemFromTable() {
        self.parentVC!.putToTrash(requestID: requestID, index: self.index)  // Call function on Parant VC on removal
        
        self.parentVC!.purchaseRequests.remove(at: self.index)  /// Remove element from Array
        self.parentVC!.tableView.beginUpdates()
        self.parentVC!.tableView.deleteRows(at: [IndexPath(item: self.index, section: 0)], with: .left)
        self.parentVC!.tableView.endUpdates()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.parentVC!.tableView.reloadData()
        })
    }

}

