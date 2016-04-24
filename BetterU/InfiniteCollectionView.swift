//
//  InfiniteCollectionView.swift
//  BetterU
//
//  Created by Hung Vu on 4/23/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

/* Creating protocols for the delegate and datasource of the infiniteCollectionView. This serves as the starting point for displaying cells on the ChangeWeightFromCustomTabViewController */
protocol InfiniteCollectionViewDataSource
{
    func cellForItemAtIndexPath(collectionView: UICollectionView, dequeueIndexPath: NSIndexPath, usableIndexPath: NSIndexPath) -> UICollectionViewCell
    func numberOfItems(collectionView: UICollectionView) -> Int
    func scrollViewDidScroll(scrollView: UIScrollView)
}

protocol InfiniteCollectionViewDelegate
{
    func didSelectCellAtIndexPath(collectionView: UICollectionView, usableIndexPath: NSIndexPath)
    func scrollViewDidEndDecelerating(scrollView: UIScrollView)
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath)
}

class InfiniteCollectionView: UICollectionView
{
    var infiniteDataSource: InfiniteCollectionViewDataSource?
    var infiniteDelegate: InfiniteCollectionViewDelegate?
    
    private var cellPadding = CGFloat(0)
    private var cellWidth = CGFloat(0)
    private var indexOffset = 0
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        dataSource = self
        delegate = self
        setupCellDimensions()
    }
    
    private func setupCellDimensions()
    {
        let layout = self.collectionViewLayout as! UICollectionViewFlowLayout
        cellPadding = layout.minimumInteritemSpacing
        cellWidth = layout.itemSize.width
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        centreIfNeeded()
    }
    
    private func centreIfNeeded()
    {
        let currentOffset = contentOffset
        let contentWidth = getTotalContentWidth()
        
        // Calculate the centre of content X position offset and the current distance from that centre point
        let centerOffsetX: CGFloat = (3 * contentWidth - bounds.size.width) / 2
        let distFromCentre = centerOffsetX - currentOffset.x
        
        if (fabs(distFromCentre) > (contentWidth / 4))
        {
            // Total cells (including partial cells) from centre
            let cellcount = distFromCentre/(cellWidth+cellPadding)
            
            // Amount of cells to shift (whole number) - conditional statement due to nature of +ve or -ve cellcount
            let shiftCells = Int((cellcount > 0) ? floor(cellcount) : ceil(cellcount))
            
            // Amount left over to correct for
            let offsetCorrection = (abs(cellcount) % 1) * (cellWidth+cellPadding)
            
            // Scroll back to the centre of the view, offset by the correction to ensure it's not noticable
            if (contentOffset.x < centerOffsetX)
            {
                //left scrolling
                contentOffset = CGPoint(x: centerOffsetX - offsetCorrection, y: currentOffset.y)
            }
            else if (contentOffset.x > centerOffsetX)
            {
                //right scrolling
                contentOffset = CGPoint(x: centerOffsetX + offsetCorrection, y: currentOffset.y)
            }
            
            // Make content shift as per shiftCells
            shiftContentArray(getCorrectedIndex(shiftCells))
            
            // Reload cells, due to data shift changes above
            self.reloadData()
        }
    }
    
    private func shiftContentArray(offset: Int)
    {
        indexOffset += offset
    }
    
    private func getTotalContentWidth() -> CGFloat
    {
        let numberOfCells = infiniteDataSource?.numberOfItems(self) ?? 0
        return CGFloat(numberOfCells) * (cellWidth + cellPadding)
    }
    
  
}

extension InfiniteCollectionView: UICollectionViewDataSource
{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let numberOfItems = infiniteDataSource?.numberOfItems(self) ?? 0
        return  3 * numberOfItems
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        return infiniteDataSource!.cellForItemAtIndexPath(self, dequeueIndexPath: indexPath, usableIndexPath: NSIndexPath(forRow: getCorrectedIndex(indexPath.row - indexOffset), inSection: 0))
    }
    
    private func getCorrectedIndex(indexToCorrect: Int) -> Int
    {
        if let numberOfCells = infiniteDataSource?.numberOfItems(self)
        {
            if (indexToCorrect < numberOfCells && indexToCorrect >= 0)
            {
                return indexToCorrect
            }
            else
            {
                let countInIndex = Float(indexToCorrect) / Float(numberOfCells)
                let flooredValue = Int(floor(countInIndex))
                let offset = numberOfCells * flooredValue
                return indexToCorrect - offset
            }
        }
        else
        {
            return 0
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        infiniteDataSource?.scrollViewDidScroll(scrollView)
    }
}


extension InfiniteCollectionView: UICollectionViewDelegate
{
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        infiniteDelegate?.didSelectCellAtIndexPath(self, usableIndexPath: NSIndexPath(forRow: getCorrectedIndex(indexPath.row - indexOffset), inSection: 0))
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        infiniteDelegate?.scrollViewDidEndDecelerating(scrollView)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        infiniteDelegate?.collectionView(collectionView, willDisplayCell: cell, forItemAtIndexPath: indexPath)
    }
    
}

extension InfiniteCollectionView
{
    override var dataSource: UICollectionViewDataSource?
        {
        didSet
        {
            if (!self.dataSource!.isEqual(self))
            {
                print("WARNING: UICollectionView DataSource must not be modified.  Set infiniteDataSource instead.")
                self.dataSource = self
            }
        }
    }
    
    override var delegate: UICollectionViewDelegate?
        {
        didSet
        {
            if (!self.delegate!.isEqual(self))
            {
                print("WARNING: UICollectionView delegate must not be modified.  Set infiniteDelegate instead.")
                self.delegate = self
            }
        }
    }
}



