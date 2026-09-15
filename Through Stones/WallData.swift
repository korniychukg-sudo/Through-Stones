import Foundation

struct StoneEntry: Identifiable {
    var kind: StoneKind
    var name: String
    var region: String
    var age: String
    var splits: String
    var weathers: String
    var lichen: String
    var note: String
    var id: String { kind.rawValue }
    var plate: String { "st_\(kind.rawValue)_builder" }
}

struct ToolEntry: Identifiable {
    var key: String
    var name: String
    var use: String
    var history: String
    var wrong: String
    var id: String { key }
    var plate: String { "tl_\(key)" }
}

struct FaultEntry: Identifiable {
    var kind: FaultKind
    var what: String
    var why: String
    var fix: String
    var id: String { kind.rawValue }
    var plate: String { "ft_\(kind.rawValue)" }
}

struct StyleEntry: Identifiable {
    var style: WallStyle
    var region: String
    var history: String
    var rules: [String]
    var stone: String
    var id: String { style.rawValue }
    var facePlate: String { "sy_face_\(style.rawValue)" }
    var sectionPlate: String { "sy_sec_\(style.rawValue)" }
}

struct FeatureEntry: Identifiable {
    var feature: WallFeature
    var how: String
    var why: String
    var wrong: String
    var id: String { feature.rawValue }
    var plate: String { "fe_\(feature.rawValue)" }
}

enum StoneLore {
    static func name(_ k: StoneKind) -> String {
        switch k {
        case .gritstone: return "Gritstone"
        case .limestone: return "Carboniferous limestone"
        case .oolite: return "Cotswold oolite"
        case .sandstone: return "Sandstone"
        case .slate: return "Slate"
        case .granite: return "Granite"
        case .whinstone: return "Whinstone"
        case .greywacke: return "Greywacke"
        case .schist: return "Schist"
        case .fieldstone: return "Fieldstone"
        case .flagstone: return "Flagstone"
        case .clunch: return "Chalk clunch"
        }
    }

    static func entry(_ k: StoneKind) -> StoneEntry { stones.first { $0.kind == k } ?? stones[0] }

    private static let stonesA: [StoneEntry] = [
        StoneEntry(kind: .gritstone, name: "Gritstone", region: "Pennines, Yorkshire Dales, Peak District", age: "Carboniferous, about 320 million years",
                   splits: "Breaks square along its bedding with a lump hammer; a coarse, sandy grain that dresses easily and holds a sharp edge.",
                   weathers: "Darkens from buff to near black on the weather side within a decade; the grain sheds sand in frost but the block stays sound.",
                   lichen: "Grey crustose patches first, then the yellow map lichen on the tops of copes after thirty years.",
                   note: "The waller's stone. Every course in the northern dales is gritstone or its cousin, and the walls stand two hundred years without a hand laid on them."),
        StoneEntry(kind: .limestone, name: "Carboniferous limestone", region: "Craven, Malham, the Burren, the Peak, Kentucky bluegrass", age: "Carboniferous, 330 to 350 million years",
                   splits: "Splits along thin clay partings into slabs; the block is hard and rings under the hammer, and the edges chip rather than cut.",
                   weathers: "Whitens. Rain dissolves the surface a few microns a year and leaves a bleached, fretted skin with sharp fossil shells standing proud.",
                   lichen: "Fast: the white walls of Malham grow grey and orange lichen within a few years because the stone is alkaline.",
                   note: "Light, bright and awkward in the hand. A limestone wall is a white line across a green hill and the sheep shelter in its lee."),
        StoneEntry(kind: .oolite, name: "Cotswold oolite", region: "Cotswolds, from Bath to Chipping Campden", age: "Jurassic, about 170 million years",
                   splits: "Comes out of the quarry in thin beds, four to ten centimetres, and cleaves with a tap; too soft for a chisel edge to last.",
                   weathers: "Honey gold when cut, greying to silver on the north side; frost picks at the beds and the face slowly rounds.",
                   lichen: "Grows the fastest of all: an oolite wall is green and grey in five years.",
                   note: "Built in thin courses because the beds are thin, with the small stones set upright along the top, the cock and hen cope."),
        StoneEntry(kind: .sandstone, name: "Sandstone", region: "Northumberland, the Scottish Borders, the Welsh Marches", age: "Carboniferous and Devonian, 300 to 400 million years",
                   splits: "Beds vary from flags to blocks; the plane is easy to read, a lighter line in the grain, and it parts there cleanly.",
                   weathers: "Softer beds hollow out first, so an old sandstone face is ribbed like a shell; iron in the stone stains it rust.",
                   lichen: "Moderate; the wetter the wall the greener the joints.",
                   note: "The most forgiving stone to learn on. If the bed is down it stays; if the bed is up it shales in the first hard winter."),
        StoneEntry(kind: .slate, name: "Slate", region: "North Wales, the Lake District, Cornwall", age: "Cambrian and Ordovician, 450 to 500 million years",
                   splits: "Cleaves into thin plates along the slaty cleavage, which is not the bedding; a waller uses the cleavage as the bed.",
                   weathers: "Barely. A slate wall looks the same after two centuries, only the edges soften and the blue turns grey-green.",
                   lichen: "Slow; the surface is too dense and acid for most crusts.",
                   note: "Thin, heavy for its size and slippery when wet. Slate fences in Wales are single slabs set on edge like a row of books."),
        StoneEntry(kind: .granite, name: "Granite", region: "Cornwall, Dartmoor, Aberdeenshire, Galloway, New England", age: "Igneous, 280 to 400 million years",
                   splits: "No bed at all. It parts along cooling joints into rough blocks and is split with plugs and feathers along a line of drilled holes.",
                   weathers: "Very slowly; the feldspar crystals rot and the surface roughens to a sandpaper skin over a century.",
                   lichen: "Grey and black crusts, slowly; the orange Xanthoria on the tops where birds sit.",
                   note: "Heavy, blocky and rounded at the corners. Granite walls are massive, low, and built with the biggest stones a horse could drag."),
        StoneEntry(kind: .whinstone, name: "Whinstone", region: "Northumberland along the Whin Sill, the Lothians", age: "Carboniferous dolerite, about 295 million years",
                   splits: "Fractures in irregular blocks with sharp corners and no bed; a hard stone that blunts the hammer and will not dress.",
                   weathers: "Rusts. The dark grey turns brown on the outside as the iron oxidises, and the corners stay sharp.",
                   lichen: "Slow to take; white patches on the sheltered side after decades.",
                   note: "Awkward, angular and unforgiving. A whin wall is built with hearting in every gap because nothing sits flat."),
        StoneEntry(kind: .greywacke, name: "Greywacke", region: "Galloway, the Southern Uplands, the Lake District", age: "Ordovician and Silurian, 420 to 460 million years",
                   splits: "Irregular; a dirty sandstone that breaks in lumps and wedges with a rough grain and a dark grey colour.",
                   weathers: "Turns from grey to a warm brown skin; the outer few millimetres soften and hold moss.",
                   lichen: "Moderate; greywacke dykes in Galloway are patched with white and grey.",
                   note: "The Galloway dyke stone. Big irregular lumps below, single stones above with the daylight showing through."),
        StoneEntry(kind: .schist, name: "Schist", region: "The Scottish Highlands, Connemara, Vermont", age: "Metamorphic, 400 to 600 million years",
                   splits: "Flakes along the foliation, a glittering plane of mica, into thin irregular slabs.",
                   weathers: "The mica catches the light for a lifetime; edges crumble and the slabs thin from the outside in.",
                   lichen: "Slow; the surface sheds water and is acid.",
                   note: "Glittering and slippery. Laid with the foliation flat it lasts; laid on edge it delaminates like a book left in the rain."),
        StoneEntry(kind: .fieldstone, name: "Fieldstone", region: "New England, the Irish midlands, glaciated lowlands everywhere", age: "Whatever the ice left: granite, gneiss, quartzite rounded by the glacier",
                   splits: "Does not split. Rounded cobbles and boulders with no flat face at all, picked out of the plough land every spring.",
                   weathers: "Already weathered by ten thousand years; the surface is smooth and takes little more.",
                   lichen: "Old lichen already on the stone when it comes out of the field.",
                   note: "The hardest stone to wall. Nothing sits, everything rocks, and every stone wants two under it and a pin behind.")
    ]

    private static let stonesB: [StoneEntry] = [
        StoneEntry(kind: .flagstone, name: "Flagstone", region: "Caithness, Orkney, the Pennine flag quarries", age: "Devonian lake bed, about 380 million years",
                   splits: "Splits into great thin sheets, a metre or more across and only a few centimetres thick, along fine laminae.",
                   weathers: "Very slowly; the laminae lift at the edges after a century and a flag can be peeled like pages.",
                   lichen: "Grey crusts on the weather face, orange on the top edge.",
                   note: "Set on end in a trench and butted edge to edge, flags make a fence with no courses at all."),
        StoneEntry(kind: .clunch, name: "Chalk clunch", region: "Cambridgeshire, Wiltshire, the chalk downs", age: "Cretaceous, about 90 million years",
                   splits: "Cuts with a saw. The hard chalk beds are soft enough to shape with a knife and too soft for a hammer.",
                   weathers: "Badly. Frost turns wet clunch to mud; a clunch wall needs a roof of thatch or tile and a plinth of harder stone.",
                   lichen: "Quickly and thickly; the surface is pure lime.",
                   note: "The weakest walling stone. Kept dry it stands for centuries; left bare it is a heap in twenty winters.")
    ]

    static let stones: [StoneEntry] = stonesA + stonesB

    private static let toolsA: [ToolEntry] = [
        ToolEntry(key: "hammer", name: "Walling hammer", use: "A two to four pound hammer with one square face and one chisel edge, for knocking off the corner that will not sit and dressing a face flush with the line.",
                  history: "The pattern has not changed since the eighteenth century enclosures; a Dales hammer has a longer, thinner peen than a Cotswold one because gritstone takes a blow that oolite does not.",
                  wrong: "Dress as little as you can. Every blow costs time and a stone that needed three blows should have gone somewhere else."),
        ToolEntry(key: "lump", name: "Lump hammer", use: "A short heavy hammer of two to four pounds with two flat faces, swung one-handed against a chisel or straight onto a stone that must be broken in two.",
                  history: "Called a club hammer in the south and a mash hammer in Scotland; the head is cast steel, the shaft ash or hickory.",
                  wrong: "Never strike stone on stone with it as an anvil: the bottom stone cracks where you cannot see it."),
        ToolEntry(key: "chisel", name: "Cold chisel", use: "A steel chisel struck with the lump hammer along a marked line to split a stone along its bed or to cut a through to length.",
                  history: "Wallers keep a pitcher, with a wide blunt edge, for taking off corners, and a point for the hardest stone.",
                  wrong: "A chisel used across the bed instead of along it shatters the stone into useless wedges."),
        ToolEntry(key: "line", name: "Line and pins", use: "A taut string between two pins or the batter frames, one for each face, raised a course at a time; the face of every stone is laid to touch it.",
                  history: "The oldest tool on the bank. Roman masons used a chalked line; the dry stone waller's is unchalked and raised by hand.",
                  wrong: "A slack line wanders and so will the wall; a line touched by a stone is pushed out and every stone after it follows."),
        ToolEntry(key: "frame", name: "Batter frame", use: "An A-shaped wooden frame the exact profile of the wall, set at each end so the string lines can be tied to it and raised together.",
                  history: "Made on the job from two battens and a crosspiece to the customer's batter; a Cornish hedger's frame is much wider than a Dales one.",
                  wrong: "Set too near plumb the wall has no lean to hold it and the wind takes the top; set too steep the cope has nothing to sit on."),
        ToolEntry(key: "bar", name: "Pinch bar", use: "A five-foot iron bar with a chisel point for levering the biggest footings into the trench and rolling a stone that two hands cannot lift.",
                  history: "Every gang had one; a footing a hundredweight and more is placed with the bar and a boot, never lifted.",
                  wrong: "Levering against a laid stone pushes it out of the face; the bar goes under, never against."),
        ToolEntry(key: "shovel", name: "Shovel", use: "For stripping the turf and cutting the foundation trench down to firm ground before a single stone is placed.",
                  history: "In the Dales the trench was cut with a spade and the turf stacked to go back on the finished hedge tops in Cornwall.",
                  wrong: "A wall started on the turf without a trench sinks unevenly in the first wet winter and the courses open."),
        ToolEntry(key: "barrow", name: "Wheelbarrow", use: "Carrying hearting and small stone along the bank; a waller sorts the heap into footings, builders, throughs and copes with the barrow.",
                  history: "Replaced the horse and sled in the nineteenth century; the professional gang still leaves the stone in heaps a stride apart along the line.",
                  wrong: "Stone barrowed a second time was put down in the wrong place the first time."),
        ToolEntry(key: "gloves", name: "Gloves", use: "Rigger gloves with a leather palm, replaced every fortnight; the hands do the reading of the stone through them.",
                  history: "Wallers a century ago worked bare-handed and were known by their fingers; gloves came with the war surplus.",
                  wrong: "Thick gloves make you drop the small pinnings; thin ones do not last a day on gritstone."),
        ToolEntry(key: "bucket", name: "Hearting bucket", use: "A bucket of small broken stone kept at hand so the core is filled as each course goes up, never left for later.",
                  history: "Hearting is the waste of the dressing and the small stuff from the heap; a good waller makes none and needs a bucket a metre.",
                  wrong: "Soil, turf or sand in the bucket instead of stone is the fastest way to a hollow wall.")
    ]

    private static let toolsB: [ToolEntry] = [
        ToolEntry(key: "tape", name: "Tape", use: "A pocket tape for the height of the throughs, the spacing along the run and the width of the top before the cope.",
                  history: "A folding rule marked in feet before 1970; a Dales wall is still described as four foot six to the cope.",
                  wrong: "Measuring every stone; the tape is for the wall, the eye is for the stone."),
        ToolEntry(key: "level", name: "Spirit level", use: "A short level for the footings and the cope, and for checking that the two faces stand at the batter of the frame.",
                  history: "Rarely used by the old hands, who judged by the line; the level came in with the competitions and the certificates.",
                  wrong: "Levelling every course. Courses only need to run reasonably level to the line; a level that is trusted more than the line makes a stiff, characterless face.")
    ]

    static let tools: [ToolEntry] = toolsA + toolsB

    private static let faultsA: [FaultEntry] = [
        FaultEntry(kind: .runningJoint, what: "A vertical joint that continues through two or more courses so that the stones above and below meet on the same line.",
                   why: "Every stone should bridge the joint beneath it: one over two, two over one. A running joint is a crack the frost has not opened yet; water gets in, ice pushes, and the wall divides into two columns that lean apart.",
                   fix: "Choose the next stone so its edges fall in the middle of the stones below; if the joints are lining up, a longer stone breaks them."),
        FaultEntry(kind: .faceBedded, what: "A stone laid with its bedding plane vertical and turned out to make the face, so the flat bed is what you see.",
                   why: "It looks tidy and it is the worst fault of all: the stone reaches only its own thickness into the wall, and the frost splits it along the bed and drops the face into the field.",
                   fix: "Every stone with its bed down and its length into the wall, however rough the face looks."),
        FaultEntry(kind: .hollowCore, what: "The space between the two faces left empty or filled with soil instead of packed hearting.",
                   why: "The faces are held apart by the core. An empty core lets the faces lean in and the top bulge out when a sheep pushes; frost heave in a hollow wall settles the courses unevenly.",
                   fix: "Hearting goes in as each course is laid, packed tight with the small stone, never left for the end."),
        FaultEntry(kind: .noThroughs, what: "A double wall built above a metre without through stones tying the two faces together.",
                   why: "Two faces leaning on hearting are two walls. Wind pressure rises with height and a face with nothing tying it in bulges and sheds its top.",
                   fix: "At half height set a through every metre or so, long enough to reach both faces, with its face flush or a little proud."),
        FaultEntry(kind: .belly, what: "A bulge in the face where a section has crept outward past the batter line.",
                   why: "The core has gone hollow or the stones behind it are traced or on edge; the face has nothing holding it in and the weight above pushes it out. A belly always grows.",
                   fix: "Strip back to sound work and rebuild with hearting packed and the length of each stone into the wall."),
        FaultEntry(kind: .onEdge, what: "A stone set with its bedding planes standing vertical instead of lying flat.",
                   why: "Frost gets into the beds from the top and splits them like pages. A stone on edge also has a narrow base and rocks; the stones above are carried on a point.",
                   fix: "Read the bed before you lift the stone, and lay it as it lay in the quarry.")
    ]

    private static let faultsB: [FaultEntry] = [
        FaultEntry(kind: .looseCope, what: "Cope stones with gaps between them, leaning, or not bedded on the top course.",
                   why: "The cope is the wall's lid and its weight holds the top course down. A loose cope is pushed off by the first ewe that rubs against it, and then the top course follows.",
                   fix: "Each cope tight against the last, upright on a level top, pinned from below where it rocks."),
        FaultEntry(kind: .poorFooting, what: "Footings set on unstripped turf, laid flat side up, too small for the job, or left rocking.",
                   why: "Everything stands on the footings. A footing that settles takes the courses above with it and opens joints you cannot reach; the biggest stones go here, flat side down, on firm ground.",
                   fix: "Strip to firm ground, bed the largest stones flat side down and level, and pin nothing at the bottom that should have been set right."),
        FaultEntry(kind: .traced, what: "A stone laid with its length along the face rather than into the wall.",
                   why: "It covers a lot of face quickly and holds nothing. A traced stone rests on the outer edge only and levers out when the core settles; it is the beginner's fault every judge looks for first.",
                   fix: "Turn the stone end on so its longest dimension runs into the core, even if the face it shows is small."),
        FaultEntry(kind: .badHead, what: "A wall head with headers and ties not alternated, not plumb, or with the courses failing to reach the end.",
                   why: "The head is the only part of the wall with a free end. Without long stones turned in alternately along the face and into the wall, the end unzips from the top down.",
                   fix: "Build the head first each course: a long header into the wall, then a tie along the face on the next, plumb to the frame."),
        FaultEntry(kind: .pinFront, what: "A rocking stone wedged with a pinning driven in from the face.",
                   why: "A pin visible on the face is a pin that works loose: it is kicked by sheep, prised by frost and falls out in a year. Pinning goes in from the back or the core where it is held.",
                   fix: "Pin from inside the wall, and use the pinning to make the stone level rather than to prop one corner."),
        FaultEntry(kind: .wrongBatter, what: "The frame set too near plumb, or leaning in so far the top is too narrow to cope.",
                   why: "The batter is the lean that lets the wall hold itself: each face leans on the core. Plumb faces are pushed over by wind and stock; too much batter and the cope has no seat and the wall is a triangle of loose hearting.",
                   fix: "Set the frame to the style, roughly one in six for a Dales wall, one in three for a Cornish hedge, and lay every face stone to the line.")
    ]

    static let faults: [FaultEntry] = faultsA + faultsB

    static func fault(_ k: FaultKind) -> FaultEntry { faults.first { $0.kind == k } ?? faults[0] }

    private static let stylesA: [StyleEntry] = [
        StyleEntry(style: .dales, region: "Yorkshire Dales, the Pennines",
                   history: "The pattern of the Parliamentary enclosures of 1780 to 1820: a double wall of gritstone, tapering from about eighty centimetres at the footings to forty at the top, with throughs at half height and a flat cope of heavy stones laid across both faces. Specifications written into the enclosure awards still describe them: four foot six to the cope, with throughs at a yard.",
                   rules: ["Two faces, hearting packed between", "Throughs at half height, every metre", "Batter about one in six on each face", "Flat cope laid across the top", "One over two in every course"],
                   stone: "Gritstone, limestone or sandstone from the nearest outcrop."),
        StyleEntry(style: .cotswold, region: "The Cotswold hills, Gloucestershire and Oxfordshire",
                   history: "Built from the thin oolitic limestone that comes out of the ground in slabs a hand thick, so a Cotswold wall has twice the courses of a Dales wall and looks like a stack of books. The top is finished with small stones set upright, alternately taller and shorter, the cock and hen cope, which sheds rain and stops sheep walking along it.",
                   rules: ["Thin courses, laid very level", "Cock and hen cope of upright stones", "Throughs where the stone allows", "Batter about one in seven", "Hearting of oolite chippings"],
                   stone: "Cotswold oolite, honey coloured when new."),
        StyleEntry(style: .galloway, region: "Galloway and Dumfriesshire, south-west Scotland",
                   history: "A dyke built to be seen through. A double base of big irregular greywacke to about half height, a course of covers across the whole width, then single large stones set one on another with daylight between them and a locked top of upright copes. Sheep will not jump a wall they can see through, and the wind goes through rather than over.",
                   rules: ["Double base with hearting to half height", "A cover band of throughs across the full width", "Single stones above, deliberately open", "Upright copes locked with wedges", "Heavy batter on the base"],
                   stone: "Greywacke and whinstone, sometimes granite."),
        StyleEntry(style: .cornish, region: "Cornwall and west Devon",
                   history: "Not a wall but a hedge: two battered stone faces around a core of rammed earth, about a metre and a half wide at the base, with turf laid along the top. Above the big grounder course the stones are set leaning, alternately one way and the other in each course, which Cornish hedgers call Jack and Jill. Some Cornish hedges are three thousand years old and still stock proof.",
                   rules: ["Two faces around an earth core, rammed as it rises", "Grounders at the base, herringbone courses above", "A batter of one in three or steeper", "Turf on top, no stone cope", "No throughs: the earth holds the faces"],
                   stone: "Granite, slate or greywacke, whatever the field gave."),
    ]

    private static let stylesB: [StyleEntry] = [
        StyleEntry(style: .aran, region: "The Aran Islands and the Burren, County Clare and Galway",
                   history: "The feidin: a double base of limestone about half a metre high with hearting, and above it a single row of tall flat slabs set upright with gaps between them. The gaps let the Atlantic gales through; a solid wall on Inishmaan would be flattened. It is quick to open for cattle, a few slabs lifted out and put back, and the fields are so small that the walls are most of the land.",
                   rules: ["Low double base with hearting", "Upright slabs above with open gaps", "Gaps of a hand or more between slabs", "No cope, no throughs", "Nearly plumb: the gaps take the wind"],
                   stone: "Grey Burren limestone, or fieldstone from the shore."),
        StyleEntry(style: .caithness, region: "Caithness and Orkney, the far north of Scotland",
                   history: "The Caithness flagstone splits into sheets a metre or more across and a few centimetres thick, and the fence is a row of these set upright in a trench, edge to edge, buried a third of their height. It has no courses, no core and no cope, and the same flags paved the streets of Edinburgh and Paris. A flag fence stands to a gale that would take a wall.",
                   rules: ["Flags set on end in a trench a third of their height", "Each flag butted tight to the next", "Set plumb, no batter", "No cope: the top edge is the top", "Pinned at the foot where a flag leans"],
                   stone: "Caithness flagstone only."),
        StyleEntry(style: .newEngland, region: "New England, from Connecticut to Maine",
                   history: "The laid walls of the New England farms were built from the fieldstone the glacier left and the plough turned up every spring: rounded boulders with no flat face, dumped along the field edge for a hundred years and then laid up into low double walls, often only waist high, with the biggest stones on top as a cope. Thoreau's country is crossed by a quarter of a million miles of them.",
                   rules: ["Double wall of rounded fieldstone", "Every stone on two below it and pinned behind", "Throughs where a long stone can be found", "Batter about one in eight", "Big flat stones laid across the top as cope"],
                   stone: "Fieldstone, granite and schist from the field."),
        StyleEntry(style: .kentucky, region: "The Bluegrass of central Kentucky",
                   history: "Built by Irish and Scots wallers who came for the railroads and stayed for the horse farms, from the blue-grey limestone that lies under the pasture in even beds. A Kentucky rock fence is a tight double wall with throughs, coursed like a Dales wall, and finished with a cope of upright stones set close and tight so a horse cannot knock them. The finest ones ran for miles along the turnpikes before 1860.",
                   rules: ["Coursed double wall of limestone", "Throughs at half height", "Batter about one in eight", "Upright cope set tight, stone against stone", "Hearting of limestone spalls"],
                   stone: "Kentucky limestone, sometimes sandstone.")
    ]

    static let styles: [StyleEntry] = stylesA + stylesB

    static func style(_ s: WallStyle) -> StyleEntry { styles.first { $0.style == s } ?? styles[0] }

    private static let featuresA: [FeatureEntry] = [
        FeatureEntry(feature: .straightRun, how: "Frames at both ends, lines pulled taut, footings in the trench and the courses laid to the line from one end to the other, hearting as you go, throughs at half height, cope to finish.",
                     why: "The plain wall is the test of everything: level courses, crossed joints, packed core, a tight cope.",
                     wrong: "Running joints and a hollow core are invisible on the day and fatal in ten years."),
        FeatureEntry(feature: .cheekEnd, how: "The free end of a wall is built first in each course: a long header laid with its length into the wall, then on the next course a tie laid along the face, alternating all the way up and plumb to the frame.",
                     why: "The head is the only place the wall has nothing to lean on. Alternating headers and ties lock the end into the run.",
                     wrong: "An end built of short stones all the same way unzips from the top."),
        FeatureEntry(feature: .corner, how: "Two walls meeting at a right angle are built as two cheek ends bonded together: the quoin stones alternate direction so each course reaches round the corner.",
                     why: "A corner takes the thrust of both walls; the quoins must be the longest stones in the heap.",
                     wrong: "A corner built as two walls butted together opens along the joint in the first winter."),
        FeatureEntry(feature: .gatePost, how: "The last half metre is a pillar of the biggest stones, alternately turned, with a through at shoulder height projecting out of the face to carry the gate's hanging hook.",
                     why: "The gate hangs on the wall, and every swing of it levers the post; the hanging stone must run right through.",
                     wrong: "A hanging stone that reaches only halfway works loose and the post follows."),
        FeatureEntry(feature: .squeezeStile, how: "A gap wide enough for a person turned sideways and too narrow for a sheep, with both sides built as cheek ends, wider at the top than the bottom.",
                     why: "A right of way across a field wall without a gate to be left open.",
                     wrong: "A stile gap that widens at the bottom lets the lambs through."),
        FeatureEntry(feature: .stepStile, how: "Three or four through stones set at rising heights on both sides, projecting a foot from the face as steps, with the cope left in place above.",
                     why: "The walker climbs the wall without touching the cope; the throughs tie the faces at the same time.",
                     wrong: "Steps that project without reaching through the wall rock and tip.")
    ]

    private static let featuresB: [FeatureEntry] = [
        FeatureEntry(feature: .lunky, how: "A square opening at the foot of the wall, about half a metre each way, with the jambs built as small cheek ends and a long lintel stone laid across the top bearing well on both.",
                     why: "A sheep creep, letting the flock move between fields while the gate stays shut; blocked with a slab when the ewes are lambing.",
                     wrong: "A lintel bearing less than a hand on each jamb cracks under the weight above."),
        FeatureEntry(feature: .curve, how: "The frames are set on the curve and the lines pulled from one to the next; the stones are shorter in the face so they can follow the bend, with more throughs than a straight run.",
                     why: "A curved wall is stronger than a straight one if the stones follow the curve, and weaker if long stones make it a polygon.",
                     wrong: "Long stones laid along a curve leave triangular gaps behind the face."),
        FeatureEntry(feature: .slope, how: "The footings are cut in level steps down the hill, and the courses run horizontal, not parallel to the slope; the cope follows the ground.",
                     why: "Stones laid parallel to a slope slide down it. Level courses stepped into the bank stay where they were put.",
                     wrong: "Courses that follow the slope creep downhill a little every winter."),
        FeatureEntry(feature: .retaining, how: "One face against the cut of a terrace, with a heavier batter, long throughs reaching back into the bank as ties, and free-draining stone packed behind.",
                     why: "The wall holds the land, and the land pushes back with every rain; the batter and the tie stones resist it.",
                     wrong: "A retaining wall built plumb, or backfilled with soil, bellies out in the first wet spring."),
        FeatureEntry(feature: .beeBole, how: "A niche in the face at chest height, about forty centimetres square, with a sill of through stones below and a lintel above, built to hold a straw skep out of the rain.",
                     why: "Before hives were wooden, the skeps stood in the wall's shelter facing the sun; the recess kept them dry.",
                     wrong: "A bole without a proper lintel is a hole waiting for a running joint.")
    ]

    static let features: [FeatureEntry] = featuresA + featuresB

    static func feature(_ f: WallFeature) -> FeatureEntry { features.first { $0.feature == f } ?? features[0] }

    static let ranks: [(Int, String, String)] = [
        (0, "Labourer", "You carry stone and watch. The bank is open to you and nothing is hidden, but the commissions are short walls in easy stone."),
        (160, "Waller", "You can be trusted with a run of wall on your own. Corners, curves and lunkies come your way now."),
        (480, "Craftsman Waller", "The awkward stone comes to you: Galloway dykes, Cornish hedges, feidins and flag fences, stiles and gate posts."),
        (1000, "Master Craftsman", "Retaining walls and bee boles, and the commissions where the client wants a master's wall and nothing less."),
        (1900, "Master Waller of the Guild", "The head of the craft. Every style, every feature, every stone, and the young wallers learn by watching you.")
    ]
}
