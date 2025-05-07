# Sightline 
A turn-based multiplayer strategy prototype with a modern military theme, built in Godot 4.

## Overview
**Sightline** is a prototype of a modern military-themed, turn-based multiplayer strategy game developed entirely in my free time as a personal hobby project. 
The main goal behind the project was to explore and learn the process of building larger-scale games - particularly focusing on networking, multiplayer systems, and working within the Godot 4 engine.

While the game is incomplete and relatively bare in terms of content and polish, it is fully playable and supports both local and non-local multiplayer. 
It features a functional turn & team systems, unit mechanics, fully-featured RTS-style camera and a tile-based map with line-of-sight considerations.

## Authors
- [Filip](https://github.com/Filip-Rak) – Design, game systems, networking, UI, and most of the content.
- [Nopee](https://github.com/fakeNopee) – Made a few (very basic) unit models and provided moral support by being vaguely around.

## Features
  - ### Camera
    Sightline features a RTS-style camera system. The camera offers a range of features commonly found in real-time strategy games allowing for smooth experience.

    - **Positional movement** – move the camera using keyboard input, speed dynamically scaling based on zoom level.
    - **Edge-based panning** – pan the camera by moving the mouse near screen edges, enabled while holding `LShift` key.
    - **Mouse-driven rotation** – rotate around the vertical and horizontal axes using `MMB` or `LCtrl` keys, with rotation clamped to prevent disorientation.
    - **Zoom functionality** – smoothly zoom in and out within configurable limits using `Scroll`.
    - **Smooth transitions** – all movement and zooming is interpolated for a responsive, polished feel.
      
  - ### Map

  Sightline uses a tile-based map where each tile type influences gameplay through movement cost, visibility, and combat modifiers. The terrain system encourages tactical positioning and unit-type awareness.
  
  Each tile has the following properties:
  - **Controlling team** – the team currently holding the tile.
  - **Value** – the number of points awarded to the controlling team each turn.
  - **Spawn** – tiles may serve as spawn points, allowing the team to purchase reinforcements.
  - **Tile type** – defines both the tile’s appearance and how units interact with it.

  Terrain features include:
  - **Tile types**: Plains, Water, Forest, Mountain, Hill, Town, River, and Bridge.
  - **Line of sight** is blocked by certain terrain (e.g., forests, hills, towns), impacting visibility and engagement ranges.
  - **Movement cost** varies, simulating terrain difficulty — rivers and forests are harder to traverse.
  - **Defense modifiers** influence incoming damage — towns and forests offer better protection.
  - **Range bonuses** are granted by elevation (e.g., hills) or open sightlines (e.g., water).
  - **Unit-specific accessibility** – some units can't cross rivers or mountains, while infantry are more versatile in complex terrain.
  - **Choke points** emerge naturally through water and bridges, rewarding smart positioning.

