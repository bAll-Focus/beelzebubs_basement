extends Node
class_name MagicManager

enum MagicType {
	POINTY_POINTY,
	SHIELDY_BREAKY
}

@rpc("any_peer")
func do_magic(mt):
	print("SHADOW WIZARD MONEY GANG, WE LOVE CASTING SPELLS ", mt)
