extends Node

const CARDID_DUCK = 0
const CARDID_SKELETON = 1
const CARDID_SOLDIER = 2
const CARDID_GOLEM = 3
const CARDID_MONKEY = 4
const CARDID_ROBOT = 5
const CARDID_UNICORN = 6
const CARDID_DINOSAUR = 7

# Element 0: power
# Element 1: name
# Element 2: ability desc
# Element 3: count
const CARD_IND_ID = 0
const CARD_IND_POWER = 0
const CARD_IND_NAME = 1
const CARD_IND_ABILITYDESC = 2
const CARD_IND_COUNT = 3
const CARDS = [
	[0, "Duck", "Can be placed over enemies of any power level", 3],
	[1, "Skeleton", "Draw two cards from reserve", 3],
	[2, "Soldier", "Play another card", 3],
	[3, "Golem", "Discard one adjacent enemy face up", 3],
	[4, "Monkey", "Can be played on bases without connection to own HQ", 3],
	[5, "Robot", "Discard one card from opponent's rack face up", 3],
	[6, "Unicorn", "Draw one card from reserve", 3],
	[7, "Dinosaur", "No special ability", 3]
]

# element 0: board name
# element 1: array of 'CARDSLOT' arrays
# element 2: array of 'AREA' arrays
# element 3: int; amt of money to win
#   see below for definition of AREA and CARDSLOT arrays
const BOARD_IND_NAME = 0
const BOARD_IND_CARDSLOTS = 1
const BOARD_IND_AREAS = 2
const BOARD_IND_MONEY = 3
const BOARDS = [
	[
		"River Crossing",
		[
			["BHQ", 1, ["1", "2"], [342, 540]],
			["1", 0, ["BHQ", "3", "5"], [342, 196]],
			["2", 0, ["BHQ", "4", "6"], [342, 884]],
			["3", 0, ["1", "5", "BrN", "BrC"], [651, 425]],
			["4", 0, ["2", "6", "BrC", "BrS"], [651, 656]],
			["5", 0, ["3", "BrN"], [651, 196]],
			["6", 0, ["4", "BrS"], [651, 884]],
			["BrC", 0, ["3", "4", "9", "10"], [960, 540]],
			["BrN", 0, ["3", "5", "7", "9"], [960, 196]],
			["BrS", 0, ["4", "6", "8", "10"], [960, 884]],
			["7", 0, ["BrN", "9"], [1269, 196]],
			["8", 0, ["BrS", "10"], [1269, 884]],
			["9", 0, ["BrN", "BrC", "7", "11"], [1269, 425]],
			["10", 0, ["BrC", "BrS", "8", "12"], [1269, 656]],
			["RHQ", 2, ["11", "12"], [1578, 540]],
			["11", 0, ["9", "RHQ"], [1578, 196]],
			["12", 0, ["10", "RHQ"], [1578, 884]]
		],
		[
			[3, ["BHQ", "1", "2", "3", "4", "BrC"], [512, 553]],
			[1, ["3", "5", "BrN"], [726, 333]],
			[1, ["4", "6", "BrS"], [696, 798]],
			[2, ["3", "9", "BrN", "BrC"], [956, 341]],
			[2, ["4", "10", "BrC", "BrS"], [944, 710]],
			[1, ["7", "9", "BrN"], [1182, 324]],
			[1, ["8", "10", "BrS"], [1216, 799]],
			[3, ["RHQ", "9", "10", "11", "12", "BrC"], [1411, 531]]
		],
		7
	],
	[
		"Arid Desert",
		[
			["BHQ", 1, ["A1", "A2"], [342, 540]],
			["A1", 0, ["BHQ", "B1"], [342, 196]],
			["A2", 0, ["BHQ", "B3"], [342, 884]],
			["B1", 0, ["A1", "B2", "C1", "C2"], [651, 196]],
			["B2", 0, ["B1", "C2", "C3", "B3"], [651, 540]],
			["B3", 0, ["A2", "B2", "C3", "C4"], [651, 884]],
			["C1", 0, ["B1", "D1"], [960, 196]],
			["C2", 0, ["B1", "B2", "D1", "D2"], [960, 425]],
			["C3", 0, ["B2", "B3", "D2", "D3"], [960, 655]],
			["C4", 0, ["B3", "D3"], [961, 884]],
			["D1", 0, ["C1", "C2", "D2", "E1"], [1269, 196]],
			["D2", 0, ["C2", "C3", "D1", "D3"], [1269, 540]],
			["D3", 0, ["C3", "C4", "D2", "E2"], [1271, 884]],
			["E1", 0, ["D1", "RHQ"], [1578, 196]],
			["E2", 0, ["D3", "RHQ"], [1578, 884]],
			["RHQ", 2, ["E1", "E2"], [1578, 540]],
		],
		[
			[3, ["A1", "A2", "BHQ", "B1", "B2", "B3"], [493, 527]],
			[1, ["B1", "B2", "C2"], [735, 423]],
			[1, ["B2", "B3", "C3"], [721, 723]],
			[2, ["B1", "C1", "C2", "D1"], [991, 316]],
			[2, ["B2", "C2", "C3", "D2"], [936, 542]],
			[2, ["B3", "C3", "C4", "D3"], [956, 772]],
			[1, ["C2", "D1", "D2"], [1212, 437]],
			[1, ["C3", "D2", "D3"], [1198, 737]],
			[3, ["E1", "E2", "RHQ", "D1", "D2", "D3"], [1427, 541]],
		],
		7
	]
]

# CARDSLOT array:
#   element 0: string; name of slot
#   element 1: int; hq (0 = regular, 1 = blue, 2 = red)
#   element 2: array of strings; names of connected neighbours
#   element 3: array of 2 ints; [x, y] position
const BOARD_CARDSLOT_IND_NAME = 0
const BOARD_CARDSLOT_IND_HQ = 1
const BOARD_CARDSLOT_IND_NEIGHBOURS = 2
const BOARD_CARDSLOT_IND_POSITION = 3

# AREA array:
#   element 0: int; num of coins (1, 2 or 3)
#   element 1: array of strings; names of bases bordering the area
#   element 2: array of 2 ints; [x, y] position
const BOARD_AREA_IND_NUMCOINS = 0
const BOARD_AREA_IND_BORDERS = 1
const BOARD_AREA_IND_POSITION = 2
