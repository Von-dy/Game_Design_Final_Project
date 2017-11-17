# Game_Design_Final_Project

Contributors:
	Madeleine Boies
	Michael von der Lippe
	Michael Russell
	Drew Merryman
	John DeMey

This Repository:
	Used to complete the final project for COSC_438 at St. Mary's College of Maryland, conducted by Professor Alan Jamieson.

Folders and Files:
 current_build - The most up-to-date and fully functional cart for the game.
 archived_builds - Previous builds of a game. build number corrisponds to batch merging of groups individual efforts.
 archived_sfx - Previous sound data for archived builds.
 archived_sprites - Previous sprite sheets for archived_builds.
 master_functions - All the current lua/pio8 code broken down into function types.
  - Master Cart -> Holds full cart of lua code
  - Master AI -> holds boss logic and attack pattern code.
  - Master Animation -> Holds special effects, drawing, and animation code.
  - Master Misc -> Holds Miscillenious functions such as collision, music, timers.
  - Master Object -> Holds Cunstructors and Make Methods
  - Master Pico8 -> Holds _init(), _update60(), _draw()
  - Master Player -> Holds functions related to player creation and movement. Override of Object for player
  ** note for debugging ** change line beginning with if ready_count=#players to change game state easily
