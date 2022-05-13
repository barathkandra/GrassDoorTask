//
//  Utilities.swift
//  MovieDBTask
//
//  Created by Barath K on 13/05/22.
//

import Foundation

class CommonMethods {
   static func changeDateFormate(strDate: String?,inputDateFormate: String = "YYYY-MM-dd",outPutDateFormate: String = "MMM d, yyyy") -> String? {
        if let expDateStr = strDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = inputDateFormate
            if let expDate = dateFormatter.date(from:expDateStr){
                dateFormatter.dateFormat = outPutDateFormate
                let fullDate = dateFormatter.string(from:expDate)
                return fullDate
            }
        }
        return nil
    }
}
