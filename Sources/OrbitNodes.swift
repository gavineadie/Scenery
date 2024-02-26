/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ OrbitNodes.swift                                                                         Scenery ║
  ║ Created by Gavin Eadie on Jan01/17.. Copyright © 2017-24 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable statement_position

import SceneKit
import SatelliteKit

import DemosKit

let celestrakBase = "https://celestrak.org/NORAD/elements/gp.php?"
var elementsStore = ElementsStore(baseName: "com.ramsaycons.SatelliteStore")
//let visualTLEs = try! String(contentsOfFile:
//                "/Users/gavin/Library/Application Support/com.ramsaycons.tle/visual.txt")
let visualGroup = ElementsGroup(groupKey: "visual")

extension ElementsGroup {

    public init(groupKey: String = "visual") {

        if let groupAge = elementsStore.ageElements(groupKey: groupKey),
               groupAge < 7.5 {

        } else {

            guard let tleURL =
                    URL(string: "\(celestrakBase)GROUP=\(groupKey)&FORMAT=tle")
                                            else { fatalError("× Celestrak URL malformed!") }

            Task {
                let visualContents = await ElementsGroup().fetchFrom(url: tleURL)
                elementsStore.insertElements(groupKey: groupKey, cacheText: visualContents)
            }
        }

        sleep(5)

        self.init(elementsStore.extractElements(groupKey: groupKey)!)
    }
}


/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ for the satellite(s) we want to display ..                                                       ┆
  ┆         .. create the STATIC dots for the orbit "O-" and groundtrack "S-" for the satellite ..   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/

public func OrbitNodes() -> SCNNode {
    let orbitNode = SCNNode(name: "orbit")

    if let elements = visualGroup.table[25544] {  // 42684
        let satellite = Satellite(elements: elements)

        if orbitNode.childNode(withName: "H-" + satellite.noradIdent, recursively: true) == nil {
            satellite.horizonNode(inFrame: orbitNode)
        }

        if orbitNode.childNode(withName: "O-" + satellite.noradIdent, recursively: true) == nil {
            satellite.orbitalNode(inFrame: orbitNode)
        }

//        if orbitNode.childNode(withName: "S-" + satellite.noradIdent, recursively: true) == nil {
//          satellite.surfaceNode(inFrame: orbitNode)
//        }

        satellite.everySecond(inFrame: orbitNode)
    }

    return orbitNode
}

public func moveOrbits(_ orbitNode: SCNNode) {
    if let elements = visualGroup.table[25544] {
        let satellite = Satellite(elements: elements)
        satellite.everySecond(inFrame: orbitNode)
    }
}


let orbTickDelta = 30                                           // seconds between marks on orbit
let orbTickRange = -5*(60/orbTickDelta)...80*(60/orbTickDelta)  // range of marks on orbital track ..
let surTickRange = -5*(60/orbTickDelta)...300*(60/orbTickDelta) // range of marks on surface track ..

let horizonVertexCount = 90

let dotSatRadius = 75.0
let dotMaxRadius = 30.0
let dotMinRadius = 15.0

public extension Satellite {

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ create (don't position) a SCNNode with a trail of dots along the satellite's orbit ..            │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func horizonNode(inFrame orbitNode: SCNNode) {
            let hTicksNode = SCNNode(name: "H-" + self.noradIdent)

            for _ in 0...horizonVertexCount {
                let dottyGeom = SCNSphere(radius: dotMaxRadius)         //
                dottyGeom.isGeodesic = true
                dottyGeom.segmentCount = 4
                dottyGeom.firstMaterial?.emission.contents = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1) // NSColor.white (!!CPU!!)
                dottyGeom.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                hTicksNode <<< SCNNode(geometry: dottyGeom)
            }

            orbitNode <<< hTicksNode
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ create (don't position) a SCNNode with a trail of dots along the satellite's orbit ..            │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func orbitalNode(inFrame orbitNode: SCNNode) {
            let oTicksNode = SCNNode(name: "O-" + self.noradIdent)

            for _ in orbTickRange {
                let dottyGeom = SCNSphere(radius: dotMaxRadius)         //
                dottyGeom.isGeodesic = true
                dottyGeom.segmentCount = 4
                dottyGeom.firstMaterial?.emission.contents = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1) // NSColor.white (!!CPU!!)
                dottyGeom.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                oTicksNode <<< SCNNode(geometry: dottyGeom)
            }

            orbitNode <<< oTicksNode
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ create (don't position) a SCNNode with a trail of dots along the satellite's groundtrack ..      │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func surfaceNode(inFrame orbitNode: SCNNode) {
            let sTicksNode = SCNNode(name: "S-" + self.noradIdent)

            for _ in surTickRange {
                let dottyGeom = SCNSphere(radius: dotMaxRadius)
                dottyGeom.isGeodesic = true
                dottyGeom.segmentCount = 4
                dottyGeom.firstMaterial?.emission.contents = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)    // (!!CPU!!)
                dottyGeom.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                sTicksNode <<< SCNNode(geometry: dottyGeom)
            }

            orbitNode <<< sTicksNode

    }

    func everySecond(inFrame frameNode: SCNNode) {

        let nowMinsAfterEpoch = (ep1950DaysNow() - self.t₀Days1950) * 1440.0

        if let oNode = frameNode.childNode(withName: "O-" + self.noradIdent,
                                           recursively: true) {
            let oDots = oNode.childNodes

            for index in orbTickRange {

                let tickMinutes = nowMinsAfterEpoch + Double(orbTickDelta*index) / 60.0
                let oSatCel = self.position(minsAfterEpoch: tickMinutes)

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ for 'orbital' track, is satellite in sunlight ?                                                  ┆
  ┆                                                    .. eclipsed dots are smaller than sunlit ones ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                let horizonAngle = acos(EarthConstants.Rₑ/magnitude(oSatCel)) * rad2deg
                let sunCel = solarCel(julianDays: julianDaysNow())
                let eclipseDepth = (horizonAngle + 90.0) - separation(oSatCel, sunCel)

                let tickIndex = index - orbTickRange.lowerBound
                oDots[tickIndex].position = SCNVector3(oSatCel.x, oSatCel.y, oSatCel.z)

                if let tickGeom = oDots[tickIndex].geometry as? SCNSphere {
                    if index == 0 {
                        tickGeom.radius = dotSatRadius

                        tickGeom.firstMaterial?.emission.contents = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                        tickGeom.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)

                    } else {
                        tickGeom.radius = eclipseDepth < 0.0 ? dotMinRadius : dotMaxRadius
                    }
                }
            }
        } else { fatalError("orbital") }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ for 'surface' track ..                                                                           ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if let sNode = frameNode.childNode(withName: "S-" + self.noradIdent,
                                           recursively: true) {
            let sDots = sNode.childNodes

            for index in surTickRange {

                let tickMinutes = nowMinsAfterEpoch + Double(orbTickDelta*index) / 60.0
                let oSatCel = self.position(minsAfterEpoch: tickMinutes)

                let jDate = self.t₀Days1950 + JD.epoch1950 + tickMinutes / 1440.0
                var lla = eci2geo(julianDays: jDate, celestial: oSatCel)
                lla.alt = 0.0                                            // altitude = 0.0 (surface)
                lla.lon -= Double(orbTickDelta*index) * EarthConstants.rotationₑ / 240.0

                let sSatCel = geo2eci(julianDays: jDate, geodetic: lla)

                let tickIndex = index - surTickRange.lowerBound
                sDots[tickIndex].position = SCNVector3(sSatCel.x, sSatCel.y, sSatCel.z)

                if index == 0 {
                    if let tickGeom = sDots[tickIndex].geometry as? SCNSphere {
                        tickGeom.radius = dotSatRadius

                        tickGeom.firstMaterial?.emission.contents = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                        tickGeom.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)

                    }
                }
            }
        } else {  }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ for 'horizon' track ..                                                                           ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if let hNode = frameNode.childNode(withName: "H-" + self.noradIdent,
                                           recursively: true) {
            let hDots = hNode.childNodes

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ get the sub-satellite point ..                                                                   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let satNowLatLonAlt = self.geoPosition(minsAfterEpoch:
                                                    (ep1950DaysNow() - self.t₀Days1950) * 1440.0)

            let satLatitudeRads = satNowLatLonAlt.lat * deg2rad
            let satLongitudeRads = satNowLatLonAlt.lon * deg2rad
            let sinSatLatitude = sin(satLatitudeRads)
            let cosSatLatitude = cos(satLatitudeRads)

            let elevationLimitRads = 5.0 * deg2rad
            let beta = acos(cos(elevationLimitRads) * EarthConstants.Rₑ /
                            (EarthConstants.Rₑ + satNowLatLonAlt.alt)) - elevationLimitRads
            let sinBeta = sin(beta)
            let cosBeta = cos(beta)

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ calculate the points around the horizon and reposition the dots ..                               ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            for index in 0...horizonVertexCount {

                let azimuthDegs = index * 360 / horizonVertexCount
                let azimuthRads = fmod2pi_0(Double(azimuthDegs) * deg2rad)

                let footDelta = asin(sinSatLatitude * cosBeta +
                                     cosSatLatitude * sinBeta * cos(azimuthRads))

                let numerator = cosBeta - sinSatLatitude * sin(footDelta)
                let denominator =         cosSatLatitude * cos(footDelta)

                var footAlpha = 0.0

                if beta > .π/2 - satLatitudeRads &&
                    (azimuthDegs == 0 || azimuthDegs == 180) { footAlpha = satLongitudeRads + .π }
                else if fabs(numerator/denominator) > 1.0 { footAlpha = satLongitudeRads }
                else {
                    if azimuthDegs < 180 { footAlpha = satLongitudeRads - acos2pi(numerator, denominator) }
                    else { footAlpha = satLongitudeRads + acos2pi(numerator, denominator) }
                }

                let eciVector = geo2xyz(julianDays: (ep1950DaysNow() - self.t₀Days1950) * 1440.0 *
                                        TimeConstants.min2day + self.t₀Days1950 + JD.epoch1950,
                                        geodetic: LatLonAlt(footDelta * rad2deg,
                                                            footAlpha * rad2deg,
                                                            0.0))

#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
                hDots[index].position = SCNVector3(Float(eciVector.x), Float(eciVector.y), Float(eciVector.z))
#else
                hDots[index].position = SCNVector3(CGFloat(eciVector.x), CGFloat(eciVector.y), CGFloat(eciVector.z))
#endif

            }
        } else { fatalError("horizon") }
    }
}
