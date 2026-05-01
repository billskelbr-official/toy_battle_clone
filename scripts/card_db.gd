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
