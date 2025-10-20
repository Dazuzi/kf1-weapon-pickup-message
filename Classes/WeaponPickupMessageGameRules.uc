class WeaponPickupMessageGameRules extends GameRules;

var WeaponPickupMessage ParentMutator;

function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup) {
	local KFWeaponPickup Weapon;
	if (item != None) {
		Weapon = KFWeaponPickup(item);
		if (Weapon != None && Other.FindInventoryType(Weapon.InventoryType) == None)
			ParentMutator.SendPickupMessage(Other.GetHumanReadableName(), Weapon.ItemName);
	}
	return Super.OverridePickupQuery(Other, item, bAllowPickup);
}
