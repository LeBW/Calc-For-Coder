//
//  statisticsBrain.swift
//  Calculator
//
//  Created by 李博文 on 22/12/2017.
//  Copyright © 2017 Nanjing University. All rights reserved.
//

import Foundation

struct StatisticsBrain
{
    static func numberOfVariables(variables: [Double]) -> Int
    {
        return variables.count
    }
    static func sumOfVariables(variables: [Double]) -> Double
    {
        var sum: Double = 0
        for item in variables
        {
            sum += item
        }
        return sum
    }
    static func meanOfVariables(variables: [Double]) -> Double
    {
        return sumOfVariables(variables: variables) / Double(variables.count)
    }
    static func varianceOfVariables(variables: [Double]) -> Double
    {
        let mean = meanOfVariables(variables: variables)
        var variance: Double = 0
        for item in variables {
            variance += (mean - item) * (mean - item)
        }
        return variance / Double(variables.count)
    }
    static func sumOfSquares(variables: [Double]) -> Double
    {
        var sum: Double = 0
        for item in variables {
            sum += item*item
        }
        return sum
    }
    static func meanOfSquare(variables: [Double]) -> Double
    {
        return sumOfSquares(variables:variables) / Double(variables.count)
    }
    static func sampleVariance(variables: [Double]) -> Double
    {
        return varianceOfVariables(variables:variables) * Double(variables.count) / Double(variables.count-1)
    }
    static func sampleDeviation(variables: [Double]) -> Double
    {
        return sqrt(sampleVariance(variables: variables))
    }
}
