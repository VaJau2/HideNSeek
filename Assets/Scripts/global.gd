extends Node

#настроен на синглтон "G" через интерфейс движка

enum GAME_STATE {IDLE, HIDING, SEARCHING}

var player: Character
var dialogueMenu
var state = GAME_STATE.IDLE
var timer
