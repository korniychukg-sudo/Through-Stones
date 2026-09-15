import Foundation

struct Lesson: Identifiable {
    var index: Int
    var title: String
    var sub: String
    var text: String
    var id: Int { index }
    var plate: String { "ls_\(index)" }
    var words: Int { text.split(separator: " ").count }
}

struct GlossEntry: Identifiable {
    var term: String
    var means: String
    var id: String { term }
}

struct ExamQuestion: Identifiable {
    var id: String
    var kind: String
    var prompt: String
    var options: [String]
    var answer: Int
    var why: String
    var plate: String?
}

enum Lessons {
    private static let a: [Lesson] = [
        Lesson(index: 0, title: "Reading a stone", sub: "Bed, face and length before you lift it",
               text: "Every stone that comes out of a quarry or a field carries three pieces of information, and a waller reads them before the stone leaves the heap. The first is the bed: the plane the stone lay in when it formed, visible as a grain in sandstone and gritstone, as fine partings in limestone, as the glitter of mica in schist. The bed is the stone's strength. Laid flat, water runs off it and frost has nothing to grip. Stood on edge, the beds face the sky like the pages of a book, water gets between them and the first hard winter splits the stone into slates.\n\nThe second is the face: the side that will show. A waller wants a face that is roughly square to the bed and not too smooth. A rough face is a face that has not been dressed, and every blow of the hammer weakens the corner it strikes. Beginners choose the prettiest face and then find the stone has no length behind it.\n\nThe third is the length, and it is the one that matters most. The longest dimension of a builder must run into the wall, not along it. A stone with its length into the core is held by the weight of everything above it along its whole length; a stone with its length along the face is a plank balanced on its edge. The only stones laid with their length along the face are the ties at a wall head and the lintel over an opening.\n\nSo the reading goes: which way is the bed, where is the face, and where is the length. If the answer is bed down, face out, length in, the stone is a builder. If the face is the bed, put it back. If the length is short and the stone is flat, it is a hearting stone or a pinning. If it is long and flat and a little longer than the wall is wide, it is a through, and it goes in the through pile to wait for half height.\n\nA good waller picks a stone up once. The reading is done with the eye on the heap, the hand confirms it, and the stone goes where it belongs. Turning a stone over four times on the wall is the sign of a stone that should not have been lifted."),
        Lesson(index: 1, title: "The trench and the footings", sub: "Strip the turf and start on firm ground",
               text: "No wall is better than its footings, and no footing is better than the ground it sits on. The first job on any bank is to strip the turf along the line of the wall to a width a little more than the wall's base, and dig down until the spade finds ground that does not give: clay, gravel, rock, or subsoil that has been undisturbed since the ice. In the Dales that is a hand's depth; on peat it can be a metre, and there the wall is built on a raft of flags.\n\nThe trench is cut flat and level across its width. On a slope it is cut in steps, each step level, so that the footings can be laid flat and the courses can run horizontal. A wall on a slope is never built parallel to the slope: stones laid on a slope slide down it, a little every winter, until the joints open.\n\nThe footings are the largest stones in the heap, the ones that need the pinch bar. Each is laid with its flattest side down, its length into the wall, and its face to the string line. They are laid from both faces inward and the middle is packed with hearting the same as any course. A footing that rocks is not pinned; it is lifted and reset with a shovel of gravel under the low corner, because a pin at the bottom of the wall carries the whole weight above it and works loose.\n\nThe footings do not need to be level with each other course-wise; they need to be firm. But the top of the footing course should present a surface the next course can sit on: no footing stone sticking up above the rest by more than a hand.\n\nWith the footings in, the batter frames are set at each end, the lines are tied to them and pulled tight, and the wall proper begins. Everything above is only as good as this: a footing that settles takes a triangle of wall with it, and the crack shows at the cope two years later, where nobody thinks to look for the cause."),
        Lesson(index: 2, title: "One over two", sub: "The rule that holds a dry wall together",
               text: "There is no mortar in a dry stone wall, so nothing holds it together except gravity and friction and the way the stones are arranged. The arrangement has one rule above all others: every stone crosses the joint below it. One stone sits over the joint between two, two sit over the middle of one. Bricklayers call it the bond; wallers say one over two, two over one.\n\nWhen the rule is followed, the wall is a single body. Push on any stone and it is held by two stones below, which are each held by two more. When the rule is broken and a vertical joint continues through two or three courses, the wall is two bodies standing side by side, and everything that happens to a wall over the years, frost heave, sheep, the roots of a thorn, a cow leaning on it, pushes those two bodies apart. The running joint is a crack the frost has not opened yet.\n\nThe rule is kept by choosing. As each stone is laid, look at the joints in the course below and choose a stone whose ends fall well away from them, a hand's width at least. If the joints are lining up, a longer stone breaks the pattern; if a run of long stones has made the joints wander into line, a short one resets them. The choosing is the craft; a waller who lays stones in the order they come to hand builds a wall full of running joints and does not know it.\n\nThe rule applies at the heads and openings too. At a wall head the stones alternate, a long header into the wall and then a tie along the face, so that the end of the wall is bonded into the run. Over a lunky or a bee bole the lintel bears well on both jambs and the courses above cross the lintel's ends.\n\nA judge reading a finished wall counts the running joints first, because they tell how carefully the waller chose. One in a wall is a fault; two together is a crack; three in a line is a wall built in a hurry."),
        Lesson(index: 3, title: "Length into the wall", sub: "Why a traced stone is the beginner's fault",
               text: "A builder stone has a length, a width and a thickness. The thickness is the bed and it lies flat. Of the other two, the longer one goes into the wall and the shorter one shows as the face. This is the rule the beginner breaks every time, because breaking it makes the wall go up faster and look better on the day.\n\nA stone laid with its length along the face is called traced. It covers a lot of face at once. It also rests on the face stones below along a narrow strip and reaches only its own width into the core. As the hearting settles behind it, nothing holds its back, and the weight of the courses above levers it outward like a lid. Every belly in an old wall has traced stones behind it.\n\nA stone with its length into the wall shows a small face, sometimes only a hand across, and reaches deep into the core, where the hearting packs around it and the stones above pin it down along its whole length. The wall is made of these, face after face, each one anchored, with the hearting locked between their tails.\n\nThere is a third way to lay a stone that is worse than either: the bed turned out to make the face. It gives the flattest, tidiest face of all, a slab standing up like a tile, and it reaches nothing into the wall at all. The frost splits it along the bed and the face slides off. It is called face-bedding and it is why old walls built by unskilled labour have lost their faces while the core stands.\n\nOn the bank, turning the stone end on takes a moment: the stone looks wrong for a second, a small rough face where a big flat one was, and then it is laid and the next one follows. The wall built this way looks rougher on the first day and stands two hundred years. The wall built the other way looks like masonry until the first winter."),
        Lesson(index: 4, title: "The batter and the frame", sub: "A wall leans on itself",
               text: "A dry stone wall is not built plumb. Each face leans inward as it rises, so that the wall is wider at the footings than at the cope, and this inward lean is called the batter. A Dales wall eighty centimetres wide at the base is forty at the top and the faces lean at about one in six. A Cornish hedge leans at one in three or more. A flag fence has no batter at all, and a feidin very little, because both are single and the wind goes through.\n\nThe batter does two things. The first is that each face leans on the core, so that any push from outside has to lift the face against the weight of the hearting behind it. A plumb face has nothing behind it but its own balance, and a sheep or a gale tips it. The second is that the weight of the cope and the upper courses is directed inward along the lean, pressing the two faces together onto the core instead of apart.\n\nThe batter is set with the frame: an A-shaped wooden frame the exact profile of the finished wall, made on the job from two battens and a crosspiece. One is set at each end of the run, plumbed, and the string lines are tied to them, one for each face, and raised together a course at a time. Every face stone is laid to touch the line. The frame is the only measuring tool most wallers use; the lines are the wall before the wall exists.\n\nToo much batter is also a fault. If the faces lean in too far, the top is too narrow to seat a cope, the core is a thin wedge of hearting with no weight to pack it, and the wall is a tent of stones that opens when the cope is knocked. The frame is made to the style and the customer's specification, and then it is trusted.\n\nA face that has crept out past the line is a belly. It shows as a bulge against the light, it always grows, and it is the sign of a hollow core or traced stones behind. There is no repair except to strip back and rebuild."),
        Lesson(index: 5, title: "Hearting and hollow walls", sub: "The middle holds the faces apart",
               text: "Between the two faces of a double wall is the core, and the core is filled with hearting: small broken stone packed tight as each course goes up. The hearting is the waste of the dressing and the small stuff from the heap, nothing smaller than an egg and nothing rounder than a fist. It is not soil, not turf, not sand, and it is not put in at the end.\n\nThe faces of a wall are two leaning stacks of stone. What stops them leaning further is the core between them, and the core only works if it is solid. A hollow core, or one filled with earth that washes out, lets the faces settle inward, and when a sheep pushes on the cope or the frost heaves the footings, the faces belly out because there is nothing behind them to lean on. Every collapsed wall on a hillside has a hollow middle: the faces lying in the grass and a ridge of soil where the core was.\n\nHearting goes in course by course. Lay the face stones on both sides, pack the middle with small stone up to the level of their tops, tapping it in with the hammer so it locks behind the tails of the builders, then lay the next course. Never build three courses of face and then pour the hearting down from the top: it does not pack, and it leaves voids that the frost finds.\n\nThe tails of the face stones are the hearting's anchors. A stone with its length into the wall has a long tail for the hearting to grip; a traced stone has none, and the hearting behind it is loose. This is why the two faults go together in a failed wall.\n\nA Cornish hedge is the exception that proves the rule: its core is earth, rammed hard as it rises, and it works because the earth is rammed and because the hedge is so wide and so battered that the faces cannot lean. A Cornish hedger who leaves the earth loose has built a wall that slumps in the first wet winter."),
        Lesson(index: 6, title: "Throughs", sub: "Tying the two faces at half height",
               text: "A double wall is two walls until something ties them together, and the tie is the through stone: a stone long enough to reach from face to face, laid across the wall at about half its height, every metre or so along the run. Its ends show on both faces, flush or a little proud, and in some districts they stick out a hand's width so the sheep cannot rub the face.\n\nThe through stone does what hearting cannot: it makes the faces one body. Wind pressure on a wall rises with its height, and above about a metre and a quarter a face with nothing tying it to the other bulges outward and eventually sheds its top. A course of throughs at half height halves the unsupported height, and the courses above sit on the throughs as on a shelf.\n\nThroughs are chosen from the heap before the wall starts. They are the long flat stones a little longer than the wall is wide at half height, and there are never enough of them, so they are set aside and not wasted as builders. In the Dales the specification is throughs at a yard; in Kentucky and New England they go in where a long enough stone can be found; a Galloway dyke has a whole course of them, the cover band, on top of the double base.\n\nA through must be laid flat and level, bed down like any other stone, and it must reach. A stone that reaches only three quarters of the way across is not a through; it is a long builder, and the far face has nothing. The hearting is packed around the through as usual, and the next course crosses its ends like any joint.\n\nWhere a stile is wanted, the throughs are the steps: three or four of them, set at rising heights, projecting a foot from the face so a walker can climb the wall without touching the cope. Where a gate hangs, a through at shoulder height projects to carry the hanging hook. The through stone is the wall's most useful part, and the first thing a judge counts after the running joints."),
        Lesson(index: 7, title: "Pinning", sub: "Stopping a rocking stone from the inside",
               text: "A stone laid on a dry wall rests on the stones below at whatever points happen to touch. If it touches at two points well apart it is stable. If it touches at one point, or at two points close together, it rocks, and a rocking stone cannot carry the courses above it: every stone laid on it rocks too, and the wall above is a stack of see-saws.\n\nThe cure is the pinning: a thin wedge of stone driven into the gap under the rocking stone until it sits firm. Pinnings are the flakes and slivers from the dressing, kept in the bucket with the hearting, and a waller uses dozens in a day. The skill is in where the pin goes. It goes in from the back of the stone, from the core side, where the hearting will lock it in and where nothing can reach it. A pin driven in from the face is a pin visible in the joint, kicked by sheep, prised by frost, gone in a year, and the stone rocks again with a course of wall on top of it.\n\nThe rule of pinning is that the pin makes the stone level, not that the pin props one corner. A stone that needs three pins to sit is the wrong stone for that place; lift it and choose another with a flatter bed. Rounded fieldstone needs a pin behind almost every stone, which is why a New England wall is slow and why its builders were said to lay every stone twice.\n\nA rocking stone that is left unpinned is the fault the years find. It works a little every time the wall is touched, grinds the stones below it into dust, and one winter it drops.\n\nThe frame check in the workshop shows pinned stones with a small mark, and the critique counts pins from the front as a fault. Pin from behind, pin to level, and if the stone will not sit with one pin, change the stone."),
        Lesson(index: 8, title: "Copes and the styles of the top", sub: "The lid that holds the wall down",
               text: "The cope is the top course, and it is not decoration. Its weight presses the two faces together onto the core, it sheds the rain that would otherwise soak the hearting, it stops sheep walking along the top, and it takes the knocks so that the courses below do not. A wall without a cope loses its top course to the first winter and its second to the first summer.\n\nEvery district has its own cope. The Dales wall has a flat cope: big heavy stones laid across both faces, overlapping a little, their weight doing the work. The Cotswold wall has the cock and hen: small stones set upright on their edges, alternately taller and shorter, tight against each other, so the rain runs off and the top is too uncomfortable to walk on. The Kentucky rock fence sets its copes upright and tight, stone against stone, so that a horse leaning on them moves the whole row or nothing. The Galloway dyke locks its uprights with wedges driven between them so the whole top is one piece. The Cornish hedge has no stone cope at all: turf is laid along the top and the grass roots bind it. The feidin and the flag fence have nothing, because their tops are the tops of single stones.\n\nWhatever the style, the same three things make a cope good. First, the top course under it is level, so the copes sit on their beds and not on a corner. Second, each cope is tight against the last: a gap is a stone waiting to be pushed off. Third, the copes are the right size for the wall: too small and they are toys the sheep knock off, too big and they crush the top course.\n\nA leaning cope is a loose cope. If the top course will not seat it, the top course is levelled with thin stones first, and if a cope still rocks it is chocked from underneath, never from the face. The sheep test in the workshop is the test of the cope: a ewe leans on the top, and the copes that go over are the ones that were not tight."),
        Lesson(index: 9, title: "Wall heads", sub: "The free end is built first",
               text: "Everywhere along a run the wall leans on itself in both directions. At a wall head, the free end at a gate, a stile, a corner or a field boundary, it has nothing to lean on, and unless the head is built properly the wall unzips from the end.\n\nThe head is built like a column of alternating stones. In one course a long header is laid with its length into the wall, its end flush with the frame. In the next course a tie is laid along the face, reaching back into the run, its end flush. Then a header, then a tie, all the way up, and the copes finish over the last. Each header holds the two faces together at the end; each tie holds the end into the run. The stones are the biggest and squarest in the heap, and a waller sorts them out before the wall starts, because there are never enough.\n\nThe head is plumb, not battered: it is the one part of a dry stone wall built with a level. And it is built first in every course, before the run, because the run has to reach the head, not the other way round. A course that arrives at the head with a hand's width to spare is filled with a sliver; a course whose last stone overhangs the head has to come out.\n\nOpenings are heads too. The jambs of a lunky or a bee bole are small cheek ends, built with the same alternation, and the lintel across the top bears at least a hand on each jamb, more if the stone allows. The two sides of a squeeze stile are heads facing each other, wider apart at the top.\n\nA judge looks at the head before the run: if it is plumb, if the headers reach in, if the ties alternate, if the courses meet it cleanly. A bad head is the most visible fault a wall can have, and it is the one the customer will point at."),
        Lesson(index: 10, title: "Walls on a slope", sub: "Level courses, stepped footings",
               text: "Half the walls in hill country run up and down a hillside, and they are built by one rule: the courses run level, and the footings are stepped. A wall built with its courses parallel to the slope is a wall built to slide. Every stone in it has a downhill edge lower than its uphill edge, every joint leans downhill, and the whole face creeps down a little each winter as the frost lifts and drops it, until the joints open and the cope walks off the bottom.\n\nSo the trench is cut in steps, each step flat and level, the length of a footing or two, and the footings are laid flat on the steps. The first course above them runs level from the bottom of the slope, and where it meets the next step up, the step's footing takes over. The result on the face is a set of level courses running into the hill, with the wall shorter uphill and taller downhill, and a cope that follows the ground.\n\nThe string line on a slope is still level. The frames are set plumb at each end and the lines raised a course at a time, and the courses are read against them the same as on the flat. Where the ground rises faster than the courses, a footing is placed on the next step and the courses continue from it.\n\nBuilding is done from the bottom of the slope upward, so that each stone is placed above and against the stones already laid and never has to be held against a fall. Throughs on a slope go in level, at half the wall's height measured from the local ground, which means they step up the hill in a line the eye can follow.\n\nThe sheep test and the frost test are harder on a sloping wall, because the whole wall is a lever on its lowest footing. Which is why on a steep bank the footings at the bottom are the biggest stones on the job, and why the old wallers put a cheek end or a big earthfast boulder at the foot of the run to hold it."),
        Lesson(index: 11, title: "Frost, roots and rebuilding", sub: "A dry stone wall's life",
               text: "A well built dry stone wall stands for two hundred years without a hand on it, and then it needs a day's work, and then it stands for two hundred more. What ends it is not weather but neglect: a single gap left unmended lets the sheep through, the sheep widen it, and in ten years the wall is two heaps with a track between.\n\nFrost is the first test. Water in the hearting freezes and swells, lifting the courses a little every night below freezing and dropping them every thaw. A packed core and crossed joints take this a thousand times and settle back where they were. A hollow core settles unevenly and the faces lean; a running joint opens a little each cycle and never quite closes; a stone on edge shales along its beds. Frost does not break good walls, it finds the faults in bad ones.\n\nRoots are slower. A thorn or an ash seeding in the joint sends roots into the hearting and lifts the stones apart as it grows, and a tree against a wall heaves the footings in a decade. The remedy is a walk along the line every autumn with a hook.\n\nStock are the third test. A ewe rubbing along the face year after year polishes the stones and finds the loose cope; a cow leaning on a corner tests the head. The cope and the throughs are what stand to the stock.\n\nWhen a section does fall, the stones are all there in the grass, and the rebuilding is the same craft as the building. The fallen section is stripped back to sound work on either side, the footings are checked and reset, the stones are sorted again into footings, builders, throughs and copes, and the gap is rebuilt to the line with the courses tied into the old work on both sides. The stones remember nothing; they go back as well as they came out, and the new work is the same age as the old the first time the lichen closes over it.\n\nIn the workshop a fallen wall can be rebuilt: the same stones come back to the heap and the field keeps the record of what stood and what fell.")
    ]

    static let all: [Lesson] = a

    static func lesson(_ i: Int) -> Lesson { all[max(0, min(all.count - 1, i))] }
}

enum Lexicon {
    private static let a: [GlossEntry] = [
        GlossEntry(term: "Batter", means: "The inward lean of each face of a wall from footing to cope, so the wall is wider at the bottom than the top."),
        GlossEntry(term: "Batter frame", means: "An A-shaped wooden frame the profile of the finished wall, set at each end so the string lines can be tied to it."),
        GlossEntry(term: "Bed", means: "The plane in which a sedimentary stone was laid down; a stone is laid with its bed flat, as it lay in the quarry."),
        GlossEntry(term: "Bee bole", means: "A niche in a wall face, about forty centimetres square, built to shelter a straw skep of bees."),
        GlossEntry(term: "Belly", means: "A bulge in the face where stones have crept out past the batter line; the sign of a hollow core or traced stones."),
        GlossEntry(term: "Builder", means: "An ordinary walling stone for the courses between the footings and the cope."),
        GlossEntry(term: "Buck and doe", means: "A cope of alternating tall and flat stones, found in the Peak and the Welsh borders."),
        GlossEntry(term: "Cheek end", means: "The finished free end of a wall, built with alternating headers and ties, plumb."),
        GlossEntry(term: "Clunch", means: "Hard chalk used as walling and building stone in the chalk counties; weak in frost."),
        GlossEntry(term: "Cock and hen", means: "The Cotswold cope of small stones set upright, alternately taller and shorter.")
    ]

    private static let b: [GlossEntry] = [
        GlossEntry(term: "Cope", means: "The top course of a wall, laid to hold the courses below down, shed rain and keep stock off the top."),
        GlossEntry(term: "Course", means: "One horizontal layer of stones the length of the wall; courses run level even on a slope."),
        GlossEntry(term: "Cover band", means: "In a Galloway dyke, the course of long stones laid right across the wall on top of the double base."),
        GlossEntry(term: "Double wall", means: "A wall with two faces and a hearted core between them, as against a single wall one stone thick."),
        GlossEntry(term: "Dressing", means: "Shaping a stone with the hammer; the less done, the better."),
        GlossEntry(term: "Dyke", means: "The Scots word for a dry stone wall; a dyker is a waller."),
        GlossEntry(term: "Face", means: "Either outer surface of the wall, or the side of a stone that shows in it."),
        GlossEntry(term: "Face-bedded", means: "A stone laid with its bed turned outward to make the face; it reaches nothing into the wall and shales in frost."),
        GlossEntry(term: "Feidin", means: "The Aran Islands wall: a low double base with tall upright slabs above, set with gaps for the wind."),
        GlossEntry(term: "Fieldstone", means: "Rounded stone picked from the plough land, left by the ice; the hardest stone to wall.")
    ]

    private static let c: [GlossEntry] = [
        GlossEntry(term: "Flag", means: "A large thin slab of stone; Caithness flags are set upright as a fence."),
        GlossEntry(term: "Footing", means: "The first course, of the largest stones, laid flat side down in the trench on firm ground."),
        GlossEntry(term: "Frost heave", means: "The lifting of the ground and the wall as water in it freezes and swells."),
        GlossEntry(term: "Galloway dyke", means: "A south-west Scottish wall with a double base and single stones above, deliberately open."),
        GlossEntry(term: "Grounder", means: "In a Cornish hedge, the big stones of the bottom course."),
        GlossEntry(term: "Header", means: "A long stone laid with its length into the wall, especially at a wall head."),
        GlossEntry(term: "Hearting", means: "The small broken stone packed into the core between the two faces as each course is laid."),
        GlossEntry(term: "Hedge", means: "In Cornwall and Devon, a stone-faced earth bank; a Cornish hedge is a wall around a core of rammed earth."),
        GlossEntry(term: "Herringbone", means: "Courses of stones laid leaning, alternately one way and the other in each course; Jack and Jill in Cornwall."),
        GlossEntry(term: "Hollow core", means: "A core left unfilled or filled with soil; the faces have nothing to lean on and belly out.")
    ]

    private static let d: [GlossEntry] = [
        GlossEntry(term: "Jack and Jill", means: "The Cornish name for herringbone courses, the stones of each course leaning against each other."),
        GlossEntry(term: "Jamb", means: "The side of an opening; built as a small cheek end."),
        GlossEntry(term: "Joint", means: "The gap between two adjacent stones in a course."),
        GlossEntry(term: "Length into the wall", means: "The rule that a builder's longest dimension runs into the core, not along the face."),
        GlossEntry(term: "Level", means: "A course is level when its top runs true to the string line within a tolerance the style allows."),
        GlossEntry(term: "Lichen", means: "The crusts that grow on stone over decades; grey and white first, orange on the tops, fastest on limestone."),
        GlossEntry(term: "Line", means: "The string stretched between the batter frames marking the face of the course being laid."),
        GlossEntry(term: "Lintel", means: "A long stone laid across an opening, bearing on both jambs."),
        GlossEntry(term: "Locked top", means: "The Galloway cope of upright stones with wedges driven between them so the row is one piece."),
        GlossEntry(term: "Lunky", means: "A sheep creep: a small opening at the foot of a wall with a lintel over it, blocked with a slab when needed.")
    ]

    private static let e: [GlossEntry] = [
        GlossEntry(term: "On edge", means: "A stone laid with its bedding planes vertical; frost splits it along the beds."),
        GlossEntry(term: "One over two", means: "The bond of dry walling: each stone crosses the joint between the two below it."),
        GlossEntry(term: "Pinning", means: "A thin wedge of stone driven under a rocking stone from the back to make it sit level."),
        GlossEntry(term: "Pitching", means: "Setting stones upright rather than flat, as in a cope or a feidin."),
        GlossEntry(term: "Plumb", means: "Vertical; a wall head is built plumb though the faces are battered."),
        GlossEntry(term: "Quoin", means: "A corner stone; the long stones alternating round a corner."),
        GlossEntry(term: "Rocking", means: "A stone that sits on one point or two close together and moves when touched."),
        GlossEntry(term: "Running joint", means: "A vertical joint continuing through two or more courses; the wall's first crack."),
        GlossEntry(term: "Shaling", means: "Splitting along the beds in frost; what a stone on edge does."),
        GlossEntry(term: "Single wall", means: "A wall one stone thick, as the top of a Galloway dyke or the whole of a feidin.")
    ]

    private static let f: [GlossEntry] = [
        GlossEntry(term: "Squeeze stile", means: "A gap in a wall wide enough for a person sideways and too narrow for a sheep."),
        GlossEntry(term: "Step stile", means: "Through stones projecting from both faces at rising heights so a walker can climb the wall."),
        GlossEntry(term: "Stripping", means: "Removing the turf and topsoil along the line of the wall before cutting the trench."),
        GlossEntry(term: "Through", means: "A stone long enough to reach from face to face, laid at about half height to tie the two faces together."),
        GlossEntry(term: "Tie", means: "A long stone laid along the face at a wall head, alternating with headers, to bond the end into the run."),
        GlossEntry(term: "Traced", means: "A stone laid with its length along the face instead of into the wall; the beginner's fault."),
        GlossEntry(term: "Trench", means: "The foundation cut down to firm ground in which the footings are laid."),
        GlossEntry(term: "Turf top", means: "The Cornish finish: turf laid along the top of the hedge instead of a stone cope."),
        GlossEntry(term: "Waller", means: "One who builds dry stone walls; a dyker in Scotland, a hedger in Cornwall."),
        GlossEntry(term: "Wall head", means: "The free end of a wall, at a gate, corner or stile."),
        GlossEntry(term: "Weathering", means: "The slow change of a stone's surface by rain, frost and lichen; gritstone darkens, limestone bleaches.")
    ]

    static let entries: [GlossEntry] = a + b + c + d + e + f
}

enum Examiner {
    private static let authoredA: [ExamQuestion] = [
        ExamQuestion(id: "a0", kind: "book", prompt: "A stone is laid with its longest dimension running along the face of the wall. What is the fault called?", options: ["Traced", "On edge", "Face-bedded", "A belly"], answer: 0, why: "A traced stone has its length along the face; it reaches little into the core and levers out as the hearting settles.", plate: nil),
        ExamQuestion(id: "a1", kind: "book", prompt: "At what height along a double wall do the through stones go?", options: ["In the footings", "At about half height", "Just under the cope", "In every course"], answer: 1, why: "Throughs go at about half height, every metre or so, to tie the two faces together where the wind pressure begins to matter.", plate: nil),
        ExamQuestion(id: "a2", kind: "book", prompt: "What does the batter of a wall mean?", options: ["The size of the cope", "The inward lean of each face", "The depth of the trench", "The spacing of the throughs"], answer: 1, why: "The batter is the inward lean of the faces, so the wall is wider at the footings than at the top and each face leans on the core.", plate: nil),
        ExamQuestion(id: "a3", kind: "book", prompt: "Where should a pinning be driven under a rocking stone?", options: ["From the face", "From the back, on the core side", "From above", "Anywhere it fits"], answer: 1, why: "A pin driven from the face is visible in the joint and works loose; from the back it is locked in by the hearting.", plate: nil),
        ExamQuestion(id: "a4", kind: "book", prompt: "Which cope is set upright, alternately taller and shorter?", options: ["Flat cope", "Cock and hen", "Locked top", "Turf top"], answer: 1, why: "The cock and hen is the Cotswold cope of small stones set on edge, tall and short alternating.", plate: nil),
        ExamQuestion(id: "a5", kind: "book", prompt: "Which style has an earth core rammed as the faces rise?", options: ["Yorkshire Dales", "Galloway dyke", "Cornish hedge", "Kentucky rock fence"], answer: 2, why: "A Cornish hedge is two battered stone faces around a core of rammed earth, with turf on top.", plate: nil),
        ExamQuestion(id: "a6", kind: "book", prompt: "A vertical joint continues through three courses. What will the frost do to it?", options: ["Nothing; frost only attacks the cope", "Open it a little each cycle until the wall divides", "Fill it with ice that holds the stones", "Move it sideways"], answer: 1, why: "A running joint is a crack the frost has not opened yet; ice in it pushes the two columns apart a little each winter.", plate: nil),
        ExamQuestion(id: "a7", kind: "book", prompt: "In a Galloway dyke, what is the cover band?", options: ["The turf on top", "A course of long stones across the full width above the double base", "The hearting", "The footings"], answer: 1, why: "The cover band is a course of throughs laid right across the dyke on top of the double base, under the single stones.", plate: nil),
        ExamQuestion(id: "a8", kind: "book", prompt: "How are the courses of a wall on a slope laid?", options: ["Parallel to the slope", "Level, with the footings stepped", "Leaning uphill", "Leaning downhill"], answer: 1, why: "Courses run level and the footings are cut in steps; stones laid parallel to a slope slide down it.", plate: nil),
        ExamQuestion(id: "a9", kind: "book", prompt: "What is hearting?", options: ["Soil packed in the core", "Small broken stone packed tight between the faces as each course goes up", "The first course", "The stones at a wall head"], answer: 1, why: "Hearting is small stone, nothing smaller than an egg, packed course by course so the faces have something solid to lean on.", plate: nil)
    ]

    private static let authoredB: [ExamQuestion] = [
        ExamQuestion(id: "b0", kind: "book", prompt: "At a wall head, what alternates course by course?", options: ["Copes and throughs", "Headers into the wall and ties along the face", "Footings and builders", "Pinnings and hearting"], answer: 1, why: "A header laid into the wall, then a tie laid along the face, all the way up, plumb to the frame.", plate: nil),
        ExamQuestion(id: "a11", kind: "book", prompt: "Which stone splits into sheets a metre across and a few centimetres thick?", options: ["Granite", "Caithness flagstone", "Whinstone", "Fieldstone"], answer: 1, why: "Caithness flagstone splits along fine laminae into great thin flags, set upright as a fence.", plate: nil),
        ExamQuestion(id: "b2", kind: "book", prompt: "Which walling stone has no bed at all and rounded corners?", options: ["Sandstone", "Cotswold oolite", "Granite", "Slate"], answer: 2, why: "Granite is igneous: no bedding, it parts along cooling joints into rough rounded blocks.", plate: nil),
        ExamQuestion(id: "b3", kind: "book", prompt: "What happens to a stone laid on edge, with its beds vertical?", options: ["It weathers slower", "Frost splits it along the beds", "It becomes a through", "Nothing"], answer: 1, why: "Water gets between the beds from the top and the frost splits the stone like pages.", plate: nil),
        ExamQuestion(id: "b4", kind: "book", prompt: "Why is a feidin built with gaps between the upright slabs?", options: ["To save stone", "So the wind goes through instead of over", "Because the slabs are too heavy", "To let lambs through"], answer: 1, why: "On Aran the gales would flatten a solid wall; the gaps let the wind through and sheep will not jump a wall they can see through.", plate: nil),
        ExamQuestion(id: "b5", kind: "book", prompt: "A lintel over a lunky should bear on each jamb by at least", options: ["A finger", "A hand's width", "Half the opening", "Nothing; it rests on the hearting"], answer: 1, why: "A lintel bearing less than a hand on each jamb cracks under the weight of the courses above.", plate: nil),
        ExamQuestion(id: "b6", kind: "book", prompt: "What is the first thing a judge counts in a finished wall?", options: ["The copes", "The running joints", "The pinnings", "The stones in the heap"], answer: 1, why: "Running joints show how carefully the waller chose each stone; they are counted before anything else.", plate: nil),
        ExamQuestion(id: "b7", kind: "book", prompt: "Which of these is NOT a fault?", options: ["A tie laid along the face at a cheek end", "A traced builder in the middle of a course", "A face-bedded stone", "A hollow core"], answer: 0, why: "Ties at the wall head are the one place a stone is properly laid with its length along the face.", plate: nil),
        ExamQuestion(id: "b8", kind: "book", prompt: "Which stone is the weakest in frost?", options: ["Whinstone", "Chalk clunch", "Gritstone", "Greywacke"], answer: 1, why: "Wet clunch turns to mud in frost; it is walled only under a roof or behind a plinth of harder stone.", plate: nil),
        ExamQuestion(id: "b9", kind: "book", prompt: "How much batter does a Cornish hedge have compared with a Dales wall?", options: ["None", "About the same", "Much more, one in three or steeper", "Much less"], answer: 2, why: "A Cornish hedge leans at one in three or more, a Dales wall at about one in six.", plate: nil)
    ]

    private static let authoredC: [ExamQuestion] = [
        ExamQuestion(id: "c0", kind: "book", prompt: "A wall over a metre and a quarter high with no throughs. Which test finds it out?", options: ["Frost", "Sheep", "Wind", "None"], answer: 2, why: "Wind pressure rises with height; a tall wall with nothing tying the faces bulges and sheds its top.", plate: nil),
        ExamQuestion(id: "c1", kind: "book", prompt: "A wall with a tight cope and a hollow core. What does the sheep test do to it?", options: ["Knocks the cope off", "Bellies the face out", "Nothing", "Drops a footing"], answer: 1, why: "The cope holds, but with nothing behind the faces a ewe leaning on the top pushes the face out where the core is empty.", plate: nil),
        ExamQuestion(id: "c2", kind: "book", prompt: "Which cope belongs to the Kentucky rock fence?", options: ["Turf", "Flat stones across the top", "Upright stones set tight against each other", "No cope"], answer: 2, why: "Kentucky fences finish with upright copes set close so a horse cannot knock a single one.", plate: nil),
        ExamQuestion(id: "c3", kind: "book", prompt: "What are the footings laid on?", options: ["The turf", "Firm ground below the stripped turf, in a trench", "A bed of sand", "The previous wall"], answer: 1, why: "The turf is stripped and the trench cut to firm ground; footings on turf sink unevenly.", plate: nil),
        ExamQuestion(id: "c4", kind: "book", prompt: "Which way up does a footing stone go?", options: ["Flattest side down", "Flattest side up", "On edge", "It does not matter"], answer: 0, why: "Flat side down on firm ground; a footing that rocks is reset, never pinned.", plate: nil),
        ExamQuestion(id: "c5", kind: "book", prompt: "What do the tails of face stones do for the hearting?", options: ["Nothing", "They give the hearting something to lock behind", "They drain it", "They replace it"], answer: 1, why: "A stone with its length into the wall has a long tail the hearting grips; a traced stone has none.", plate: nil),
        ExamQuestion(id: "c6", kind: "book", prompt: "A stone rocks on the wall and will not sit with one pin. What should you do?", options: ["Use three pins", "Pin it from the face", "Lift it and choose a stone with a flatter bed", "Leave it; the next course holds it"], answer: 2, why: "A stone that needs three pins is the wrong stone for that place.", plate: nil),
        ExamQuestion(id: "c7", kind: "book", prompt: "Which tool sets the profile of the wall?", options: ["The lump hammer", "The batter frame", "The tape", "The pinch bar"], answer: 1, why: "The batter frame is the wall's profile in wood; the lines are tied to it and raised course by course.", plate: nil),
        ExamQuestion(id: "c8", kind: "book", prompt: "A step stile is made of what?", options: ["A gate", "Through stones projecting at rising heights", "A gap in the wall", "A ladder"], answer: 1, why: "Three or four throughs set at rising heights project from the face as steps.", plate: nil),
        ExamQuestion(id: "c9", kind: "book", prompt: "Why does a Galloway dyke stand to sheep though it is open?", options: ["The gaps are too small to see", "Sheep will not jump a wall they can see through", "It is too high", "It is mortared"], answer: 1, why: "The daylight through the single stones unsettles sheep; they will not jump what they can see through.", plate: nil)
    ]

    private static let authoredD: [ExamQuestion] = [
        ExamQuestion(id: "d0", kind: "book", prompt: "How often should a good waller lift each stone?", options: ["Once", "Twice", "Until it fits", "As often as needed"], answer: 0, why: "The reading is done with the eye on the heap; a stone turned over four times should not have been lifted.", plate: nil),
        ExamQuestion(id: "d1", kind: "book", prompt: "What is a lunky?", options: ["A cope stone", "A sheep creep at the foot of a wall with a lintel over it", "A corner", "A batter frame"], answer: 1, why: "A lunky lets the flock through while the gate stays shut and is blocked with a slab at lambing.", plate: nil),
        ExamQuestion(id: "d2", kind: "book", prompt: "Which stone weathers by bleaching white and growing lichen fastest?", options: ["Slate", "Limestone", "Granite", "Whinstone"], answer: 1, why: "Rain dissolves the surface of limestone and leaves it white and fretted; being alkaline it grows lichen within years.", plate: nil),
        ExamQuestion(id: "d3", kind: "book", prompt: "Where does the hanging stone of a gate post go?", options: ["In the footings", "At shoulder height, projecting from the face, running right through", "On top as a cope", "Beside the gate on the ground"], answer: 1, why: "The gate hangs on a through at shoulder height; every swing levers the post, so the stone must run right through.", plate: nil),
        ExamQuestion(id: "d4", kind: "book", prompt: "When is the hearting put in?", options: ["After the cope", "Course by course as the faces go up", "Before the footings", "Only at the throughs"], answer: 1, why: "Hearting poured down from the top does not pack; it goes in as each course is laid.", plate: nil),
        ExamQuestion(id: "d5", kind: "book", prompt: "What is face-bedding?", options: ["Laying the bed flat", "Turning the bed outward to make the face", "Dressing the face", "Laying a cope flat"], answer: 1, why: "The bed turned out gives a tidy face and reaches nothing into the wall; frost splits it and the face falls.", plate: nil)
    ]

    static let authored: [ExamQuestion] = authoredA + authoredB + authoredC + authoredD

    static func faultQuestion(rng: inout Spool) -> ExamQuestion {
        let kinds = FaultKind.allCases
        let target = rng.pick(kinds)
        var options = [target]
        while options.count < 4 {
            let k = rng.pick(kinds)
            if !options.contains(k) { options.append(k) }
        }
        var order: [FaultKind] = []
        var pool = options
        while !pool.isEmpty { order.append(pool.remove(at: rng.int(0, pool.count - 1))) }
        let entry = StoneLore.fault(target)
        return ExamQuestion(id: "fault.\(target.rawValue).\(rng.next() % 1000)", kind: "face", prompt: "Spot the fault in this face.",
                            options: order.map { $0.name }, answer: order.firstIndex(of: target) ?? 0,
                            why: entry.what + " " + entry.why, plate: entry.plate)
    }

    static func styleQuestion(rng: inout Spool) -> ExamQuestion {
        let target = rng.pick(WallStyle.allCases)
        var options = [target]
        while options.count < 4 {
            let k = rng.pick(WallStyle.allCases)
            if !options.contains(k) { options.append(k) }
        }
        var order: [WallStyle] = []
        var pool = options
        while !pool.isEmpty { order.append(pool.remove(at: rng.int(0, pool.count - 1))) }
        let entry = StoneLore.style(target)
        return ExamQuestion(id: "style.\(target.rawValue).\(rng.next() % 1000)", kind: "style", prompt: "Which style is this wall built in?",
                            options: order.map { $0.name }, answer: order.firstIndex(of: target) ?? 0,
                            why: entry.rules.joined(separator: "; ") + ".", plate: rng.chance(0.5) ? entry.facePlate : entry.sectionPlate)
    }

    static func testQuestion(rng: inout Spool) -> ExamQuestion {
        let cases: [(String, Int, String)] = [
            ("A double wall a metre and a half high, built with a packed core and a tight cope, but with no throughs at all.", 2, "Above head height a wall with nothing tying the faces bulges in the wind and sheds its top; the core and cope do not help against lateral pressure."),
            ("A wall with three running joints in a line, throughs at a yard and a good cope.", 0, "Frost opens the running joints a little each winter until the sections either side divide."),
            ("A wall with a hollow core and copes set with gaps between them.", 1, "A ewe leaning on the top pushes the loose copes over and bellies the face where the core is empty."),
            ("A Caithness flag fence with every flag bedded in the trench and butted tight, no batter.", 3, "A flag fence bedded a third of its height and butted tight stands to all three."),
            ("A well built Dales wall with one footing laid on unstripped turf.", 3, "The frost, sheep and wind may all pass, but over a hundred years roots and settlement under that footing drop the section above it."),
            ("A wall with several stones set on edge in soft oolite.", 0, "Frost splits stones on edge along their beds; in soft stone they shale and fall out of the face."),
            ("A wall built plumb, with no batter, a metre and a half high.", 2, "A plumb face has nothing leaning on the core; the wind pushes it over first."),
            ("A feidin built with the upright slabs tight together, no gaps.", 2, "A solid feidin takes the whole gale on its face; the gaps are what let it stand.")
        ]
        let (desc, answer, why) = rng.pick(cases)
        return ExamQuestion(id: "test.\(rng.next() % 100000)", kind: "test", prompt: "\(desc) Which test will it fail first?",
                            options: ["Frost", "Sheep", "Wind", "It passes all three"], answer: answer, why: why, plate: nil)
    }

    static func stoneQuestion(rng: inout Spool) -> ExamQuestion {
        let cases: [(String, Int, String)] = [
            ("A gap thirty centimetres wide at half height in a Dales wall, with a joint below it near the middle.", 1, "Half height is where the throughs go, and a through bridges the joint below like any builder."),
            ("The bottom of the trench, on firm ground, at the start of a run.", 0, "The footings are the largest stones, flat side down on firm ground."),
            ("A gap the width of a hand between two stones in a course, behind the face.", 3, "Small gaps in the core are packed with hearting as the course goes up."),
            ("A stone that rocks on one point, needing something under its back corner.", 2, "A pinning driven from the back makes the stone sit level."),
            ("The top of the wall after the last course, on a Cotswold wall.", 4, "The cope goes on top; on a Cotswold wall the cock and hen, set upright."),
            ("The free end of the wall, in the course above a header.", 5, "Headers and ties alternate at the head; above a header comes a tie laid along the face."),
            ("Across the top of a lunky, bearing on both jambs.", 6, "Only a lintel, a long stone laid along the face, may span an opening."),
            ("The single row above the double base of a feidin.", 7, "A tall flat slab set upright with a gap beside it.")
        ]
        let picked = rng.int(0, cases.count - 1)
        let (desc, answerIndex, why) = cases[picked]
        let names = ["A footing, flat side down", "A through, length across the wall", "A pinning from the back", "Hearting", "A cope stone", "A tie along the face", "A lintel", "An upright slab"]
        var options = [answerIndex]
        while options.count < 4 {
            let k = rng.int(0, names.count - 1)
            if !options.contains(k) { options.append(k) }
        }
        var order: [Int] = []
        var pool = options
        while !pool.isEmpty { order.append(pool.remove(at: rng.int(0, pool.count - 1))) }
        return ExamQuestion(id: "stone.\(picked).\(rng.next() % 1000)", kind: "stone", prompt: "\(desc) Which stone goes here?",
                            options: order.map { names[$0] }, answer: order.firstIndex(of: answerIndex) ?? 0, why: why, plate: nil)
    }

    static func paper(seed: UInt64) -> [ExamQuestion] {
        var rng = Spool(seed)
        var out: [ExamQuestion] = []
        var pool = authored
        for _ in 0..<6 where !pool.isEmpty { out.append(pool.remove(at: rng.int(0, pool.count - 1))) }
        func add(_ make: (inout Spool) -> ExamQuestion) {
            var q = make(&rng)
            var tries = 0
            while (out.contains { $0.id == q.id || $0.prompt == q.prompt }) && tries < 12 { q = make(&rng); tries += 1 }
            out.append(q)
        }
        add(faultQuestion)
        add(faultQuestion)
        add(styleQuestion)
        add(styleQuestion)
        add(testQuestion)
        add(testQuestion)
        add(stoneQuestion)
        add(stoneQuestion)
        return out
    }
}

enum Badges {
    static let list: [(String, String, String)] = [
        ("first", "First Stone", "A wall left in the field."),
        ("standing", "A Standing Wall", "A wall scored forty or better."),
        ("sound", "A Sound Wall", "A wall scored sixty five or better."),
        ("master", "A Master's Wall", "A wall scored eighty five or better."),
        ("frost", "Stood the Frost", "A wall that passed the frost test."),
        ("century", "The Hundred Years", "A wall that stood the hundred years."),
        ("throughs", "Through and Through", "Ten throughs laid at half height."),
        ("pinner", "Pinned from Behind", "Twenty stones pinned from the back and none from the front."),
        ("styles", "Eight Styles", "A wall left in the field in every style."),
        ("features", "Every Feature", "A wall of every feature left in the field."),
        ("stones", "Twelve Stones", "A wall built in every kind of stone."),
        ("efficient", "Picked Up Once", "A wall of forty stones with every stone picked up once."),
        ("rebuilt", "Rebuilt from the Grass", "A fallen wall rebuilt with its own stones."),
        ("reader", "Read the Book", "All twelve lessons read."),
        ("scholar", "The Whole Glossary", "Every term in the glossary read."),
        ("examined", "Examined", "Seventy percent or better in the examination."),
        ("streak", "Seven Days on the Bank", "A seven day streak."),
        ("field", "A Field of Walls", "Twelve walls standing in the field."),
        ("dawn", "First Light", "A wall left in the field before seven in the morning."),
        ("gale", "Stood the Gale", "A wall over a metre and a quarter that passed the wind test.")
    ]
}
