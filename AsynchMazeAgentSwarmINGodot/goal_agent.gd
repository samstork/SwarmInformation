class_name Goal
extends CharacterBody2D

enum State {EXPLORING, BEACON, SUBGOAL, SUBGOAL_F, BACKTRACK_B, BACKTRACK_G, EXPLOITING}
var current_state = State.SUBGOAL
