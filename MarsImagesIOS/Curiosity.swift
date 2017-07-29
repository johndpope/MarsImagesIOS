//
//  Curiosity.swift
//  MarsImagesIOS
//
//  Created by Mark Powell on 7/28/17.
//  Copyright © 2017 Mark Powell. All rights reserved.
//

import Foundation

class Curiosity: Mission {
    
    let SOL = "Sol"
    let LTST = "LTST"
    let RMC = "RMC"

    enum TitleState {
        case    START,
        SOL_NUMBER,
        IMAGESET_ID,
        INSTRUMENT_NAME,
        MARS_LOCAL_TIME,
        DISTANCE,
        YAW,
        PITCH,
        ROLL,
        TILT,
        ROVER_MOTION_COUNTER
    }
    
    override init() {
        super.init()
        var comps = DateComponents()
        comps.day=6
        comps.month=8
        comps.year=2012
        comps.hour=6
        comps.minute=30
        comps.second=00
        comps.timeZone = TimeZone(abbreviation: "UTC")
        self.epoch = Calendar.current.date(from: comps)
    }
    
    override func rowTitle(_ title: String) -> String {
        return tokenize(title).instrumentName
    }
    
    override func tokenize(_ title: String) -> Title {
        let msl = Title()
        let tokens = title.components(separatedBy: " ")
        var state = TitleState.START
        for word in tokens {
            if word == SOL {
                state = TitleState.SOL_NUMBER
                continue
            }
            else if word == LTST {
                state = TitleState.MARS_LOCAL_TIME
                continue
            }
            else if word == RMC {
                state = TitleState.ROVER_MOTION_COUNTER
                continue
            }
            var indices:[Int] = []
            switch (state) {
            case .START:
                break
            case .SOL_NUMBER:
                msl.sol = Int(word)!
                state = TitleState.IMAGESET_ID
                break
            case .IMAGESET_ID:
                msl.imageSetID = word
                state = TitleState.INSTRUMENT_NAME
                break
            case .INSTRUMENT_NAME:
                if msl.instrumentName.isEmpty {
                    msl.instrumentName = String(word)
                } else {
                    msl.instrumentName.append(" \(word)")
                }
                break
            case .MARS_LOCAL_TIME:
                msl.marsLocalTime = word
                break
            case .ROVER_MOTION_COUNTER:
                indices = word.components(separatedBy: "-").map { Int($0)! }
                msl.siteIndex = indices[0]
                msl.driveIndex = indices[1]
                break
            default:
                print("Unexpected state in parsing image title: \(state)")
                break
            }
        }
        return msl
    }

}