/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ OrbitNodes.swift                                                                         Scenery ║
  ║ Created by Gavin Eadie on Jan01/17.. Copyright © 2017-25 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import SceneKit
import DemosKit
import SatelliteKit

var elementsGroup: ElementsGroup?

public func moveOrbits(_ orbitNode: SCNNode) {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ if orbitNode.childNodes.count = 0, we don't have elements yet .. so keep trying ..               ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    if orbitNode.childNodes.count == 0 { makeOrbitNodes(orbitNode: orbitNode) }

    if elementsGroup == nil {
        sceneryLog.log("       TimelineView (1s)| moveOrbits() -- elementsGroup == nil")
        elementsGroup = loadGroup("visual")
        return
    }

    if let elements = elementsGroup?.table[25544] { // [59588] {
        Satellite(elements: elements).everySecond(orbitNode: orbitNode)
    }
}

public extension Satellite {

    func everySecond(orbitNode: SCNNode) {

        let nowMinsAfterEpoch = (ep1950DaysNow() - self.t₀Days1950) * 1440.0

        if let oNode = orbitNode.childNode(withName: "O-" + noradIdent,
                                           recursively: true) {
            let oDots = oNode.childNodes

            for index in orbTickRange {

                let tickMinutes = nowMinsAfterEpoch + Double(orbTickDelta*index) / 60.0
                let oSatCel = try! self.position(minsAfterEpoch: tickMinutes)

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
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ for 'surface' track ..                                                                           ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if let sNode = orbitNode.childNode(withName: "S-" + self.noradIdent,
                                           recursively: true) {
            let sDots = sNode.childNodes

            for index in surTickRange {

                let tickMinutes = nowMinsAfterEpoch + Double(orbTickDelta*index) / 60.0
                let oSatCel = try! self.position(minsAfterEpoch: tickMinutes)

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
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ for 'horizon' track ..                                                                           ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if let hNode = orbitNode.childNode(withName: "H-" + self.noradIdent,
                                           recursively: true) {
            let hDots = hNode.childNodes

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ get the sub-satellite point ..                                                                   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let satNowLatLonAlt = try! self.geoPosition(minsAfterEpoch:
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

                let azimuthDegs: Double = 2.0 + Double((index * 360 / horizonVertexCount))
                let azimuthRads: Double = fmod2pi_0(Double(azimuthDegs) * deg2rad)

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
        }
    }
}
