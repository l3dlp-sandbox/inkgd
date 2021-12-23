# warning-ignore-all:shadowed_variable
# warning-ignore-all:unused_class_variable
# ############################################################################ #
# Copyright © 2015-present inkle Ltd.
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

# ############################################################################ #
# !! VALUE TYPE
# ############################################################################ #

tool

class_name InkStateElement

# ############################################################################ #

enum State {
	NONE,
	OBJECT,
	ARRAY,
	PROPERTY,
	PROPERTY_NAME,
	STRING,
}

# ############################################################################ #

var type: int = State.NONE # State
var child_count: int = 0

# ############################################################################ #

func _init(type: int):
	self.type = type

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type) -> bool:
	return type == "StateElement" || .is_class(type)

func get_class() -> String:
	return "StateElement"
