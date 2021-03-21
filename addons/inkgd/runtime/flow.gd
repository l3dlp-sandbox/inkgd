# ############################################################################ #
# Copyright © 2015-present inkle Ltd.
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends Reference

# ############################################################################ #
# Imports
# ############################################################################ #

var Utils = preload("res://addons/inkgd/runtime/extra/utils.gd")

var CallStack = load("res://addons/inkgd/runtime/call_stack.gd")

# ############################################################################ #

var name # string
var call_stack # CallStack
var output_stream # Array<InkObject>
var current_choices # Array<Choice>

func _init():
	pass

func _init_with_name(name, story):
	self.name = name
	self.call_stack = CallStack.new(story)
	self.output_stream = []
	self.current_choices = []

func _init_with_name_and_jobject(name, story, jobject):
	self.name = name
	self.call_stack = CallStack.new(story)
	self.call_stack.set_json_token(jobject["callstack"], story)
	self.output_stream = self.Json.jarray_to_runtime_obj_list(jobject["outputStream"])
	self.current_choices = self.Json.jarray_to_runtime_obj_list(jobject["currentChoices"])
	
	# jchoice_threads_obj is null if 'choiceThreads' doesn't exist.
	var jchoice_threads_obj = jobject.get("choiceThreads");
	self.load_flow_choice_threads(jchoice_threads_obj, story)

# (SimpleJson.Writer) -> void
func write_json(writer):
	writer.write_object_start()
	writer.write_property("callstack", funcref(self.call_stack, "write_json"))
	writer.write_property(
		"outputStream",
		funcref(self, "_anonymous_write_property_output_stream")
	)
	
	var has_choice_threads = false
	for c in self.current_choices:
		c.orginal_thread_index = c.thread_at_generation.thread_index
		
		if self.call_stack.thread_with_index(c.original_thread_index) == null:
			if !has_choice_threads:
				has_choice_threads = true
				writer.write_property_start("choiceThreads")
				writer.write_object_start()
			
			writer.write_property_start(c.original_thread_index)
			c.thread_at_generation.write_json(writer)
			writer.write_property_end()
	
	if has_choice_threads:
		writer.write_object_end()
		writer.write_property_end()
	
	writer.write_property(
		"currentChoices",
		funcref(self, "_anonymous_write_property_current_choices")
	)
	
	writer.write_object_end()

# (Dictionary, Story) -> void
func load_flow_choice_threads(jchoice_threads, story):
	for choice in current_choices:
		var found_active_thread = self.call_stack.thread_with_index(choice.original_thread_index)
		if found_active_thread != null:
			choice.thread_at_generation = found_active_thread.copy()
		else:
			var jsaved_choice_thread = jchoice_threads[str(choice.original_thread_index)]
			choice.thread_at_generation = CallStack.InkThread.new_with(jsaved_choice_thread, story)

# (SimpleJson.Writer) -> void
func _anonymous_write_property_output_stream(w):
	self.Json.write_list_runtime_objs(w, self.output_stream)

# (SimpleJson.Writer) -> void
func _anonymous_write_property_current_choices(w):
	w.write_array_start()
	for c in self.current_choices:
		self.Json.write_choice(w, c)
	w.write_array_End()

func equals(ink_base) -> bool:
	return false

func to_string() -> String:
	return str(self)

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "InkBase" || .is_class(type)

func get_class():
	return "InkBase"

# ############################################################################ #
var Json setget , get_Json
func get_Json():
	return _Json.get_ref()

var _Json = WeakRef.new()

func get_static_json():
	var InkRuntime = Engine.get_main_loop().root.get_node("__InkRuntime")

	Utils.assert(InkRuntime != null,
				 str("Could not retrieve 'InkRuntime' singleton from the scene tree."))

	_Json = weakref(InkRuntime.json)
