# warning-ignore-all:unused_class_variable
# ############################################################################ #
# Copyright © 2015-present inkle Ltd.
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

# Simple replacement of the StringWriter class from the .NET Framework.
# It has none of the optimisations of original class and merely wraps
# a plain old string.

tool

class_name InkStringWriter

# ############################################################################ #

var _internal_string: String = ""

# ############################################################################ #

func _init():
	pass

# ############################################################################ #

func write(s: String) -> void:
	_internal_string += str(s)

func to_string() -> String:
	return _internal_string
