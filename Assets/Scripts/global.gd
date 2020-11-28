extends Node

enum GAME_STATE {IDLE, HIDING, SEARCHING}

var player: Character
var dialogueMenu
var state = GAME_STATE.IDLE
