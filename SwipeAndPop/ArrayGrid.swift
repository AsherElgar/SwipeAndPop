//
//  ArrayGrid.swift
//  SwipeAndPop
//
//  Created by Asher Elgar on 2.10.2017.
//  Copyright © 2017 Asher Elgar. All rights reserved.
//



struct ArrayGrid<T> {
    let columns: Int
    let rows: Int
    fileprivate var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        array = Array<T?>(repeating: nil, count: columns * rows)
    }
    
    subscript(column: Int, row: Int) -> T? {
        get {
           // print("row: \(row)----<><><>--- column: \(column)")
            if row <= 8 && column <= 8 && row >= 0 {
            return array[row * columns + column]
            }
            print(" out the if statment >>> row: \(row)----<><><>--- column: \(column)")
            return array[8 * columns + 8]
        }
        set {
            array[row * columns + column] = newValue
        }
    }
}
