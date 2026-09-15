import Foundation

let args = CommandLine.arguments
let outDir = args.count > 1 ? args[1] : "Art"
let job = args.count > 2 ? args[2] : "all"

try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

func wants(_ name: String) -> Bool { job == "all" || job == name }

let started = Date()
var made = 0

func note(_ text: String) {
    let elapsed = Int(Date().timeIntervalSince(started))
    print("[\(elapsed)s] \(text)")
}

if job == "icon" {
    drawIcon(outDir)
    note("icon written to \(outDir)")
    exit(0)
}

sheetScale = 1.0

if wants("stones") {
    for kind in StoneKind.allCases {
        for cls in [StoneClass.footing, .builder, .through, .cope, .hearting] {
            drawStonePlate(kind: kind, cls: cls, dir: outDir)
            made += 1
        }
    }
    note("stones: \(made)")
}

if wants("weather") {
    for g in weatherGroups() {
        for a in weatherAges {
            drawWeatherPlate(group: g, age: a, dir: outDir)
            made += 1
        }
    }
    note("weather done: \(made)")
}

if wants("walls") {
    for style in WallStyle.allCases {
        drawStylePlates(style, dir: outDir)
        made += 2
    }
    for feature in WallFeature.allCases {
        drawFeaturePlate(feature, dir: outDir)
        made += 1
    }
    note("walls done: \(made)")
}

if wants("faults") {
    for kind in FaultKind.allCases {
        drawFaultPlate(kind, dir: outDir)
        made += 1
    }
    note("faults done: \(made)")
}

if wants("tools") {
    for tool in StoneLore.tools {
        drawToolPlate(tool, dir: outDir)
        made += 1
    }
    note("tools done: \(made)")
}

if wants("lessons") {
    for lesson in Lessons.all {
        drawLessonPlate(lesson, dir: outDir)
        made += 1
    }
    note("lessons done: \(made)")
}

if wants("fell") {
    for index in 0..<fellHours.count {
        drawFellPlate(index, dir: outDir)
        made += 1
    }
    for index in 0..<4 {
        drawOnboardPlate(index, dir: outDir)
        made += 1
    }
    for key in decorKeys {
        drawDecorPlate(key, dir: outDir)
        made += 1
    }
    note("fell, onboarding and decor done: \(made)")
}

note("wrote \(made) plates into \(outDir)")
