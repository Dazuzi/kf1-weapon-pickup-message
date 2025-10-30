class WeaponPickupMessage extends Mutator
	config(WeaponPickupMessage);

var string NameCode, WeaponCode, MessageCode, LastPickup;
var config color NameColour, WeaponColour, MessageColour;
var config string WeaponPickupMessage;
var config bool bPreventSpam;

static function FillPlayInfo(PlayInfo PlayInfo) {
	Super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting("Weapon Pickup Message", "bPreventSpam",		"Prevent spam",		0, 1,	"Check");
	PlayInfo.AddSetting("Weapon Pickup Message", "WeaponPickupMessage",	"Pickup message",	0, 2,	"Text",	"256");
}

static event string GetDescriptionText(string Property) {
	switch (Property) {
		case "bPreventSpam":
			return "Prevents repeated pickup messages from appearing for the same weapon.";
		case "WeaponPickupMessage":
			return "The weapon pickup message is used when a player picks up a gun. %name% gets replaced with player's name and %weapon% with the gun the player picked up.";
		default:
			return Super.GetDescriptionText(Property);
	}
}

function SendPickupMessage(string Player, string Weapon) {
	local Controller C;
	local string Message, Pickup;
	Pickup = Player@Weapon;
	if (bPreventSpam && Pickup == LastPickup)
		return;
	LastPickup = Pickup;
	Message = Repl(Repl(MessageCode$WeaponPickupMessage, "%name%", NameCode$Player$MessageCode), "%weapon%", WeaponCode$Weapon$MessageCode);
	for (C = Level.ControllerList; C != None; C = C.nextController) {
		if (C.IsA('PlayerController')) {
			if (C.PlayerReplicationInfo.PlayerName ~= "WebAdmin" && C.PlayerReplicationInfo.PlayerID == 0)
				PlayerController(C).TeamMessage(None, Repl(Repl(Repl(Message, MessageCode, ""), NameCode, ""), WeaponCode, ""), 'WeaponPickupMessage');
			else
				PlayerController(C).TeamMessage(None, Message, 'WeaponPickupMessage');
		}
	}
}

function PostBeginPlay() {
	local GameRules GR;
	Super.PostBeginPlay();
	GR = spawn(class'WeaponPickupMessageGameRules');
	WeaponPickupMessageGameRules(GR).ParentMutator = Self;
	if (Level.Game.GameRulesModifiers == None)
		Level.Game.GameRulesModifiers = GR;
	else Level.Game.GameRulesModifiers.AddGameRules(GR);
	NameCode = class'Engine.GameInfo'.static.MakeColorCode(NameColour);
	WeaponCode = class'Engine.GameInfo'.static.MakeColorCode(WeaponColour);
	MessageCode = class'Engine.GameInfo'.static.MakeColorCode(MessageColour);
}

defaultproperties {
	bPreventSpam=True
	WeaponPickupMessage="%name% picked up %weapon%"
	NameColour=(B=0,G=155,R=0,A=255)
	WeaponColour=(B=0,G=155,R=0,A=255)
	MessageColour=(B=255,G=255,R=255,A=255)
	GroupName="KF-WeaponPickupMessage"
	FriendlyName="Weapon Pickup Message"
	Description="This mutator shows a message when a player picks up a gun."
}
