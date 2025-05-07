# Sightline 
A turn-based multiplayer strategy prototype with a modern military theme, built in Godot 4.

## Overview
**Sightline** is a prototype of a modern military-themed, turn-based multiplayer strategy game developed entirely in my free time as a personal hobby project. 
The main goal behind the project was to explore and learn the process of building larger-scale games - particularly focusing on networking, multiplayer systems, and working within the Godot 4 engine.

While the game is incomplete and relatively bare in terms of content and polish, it is fully playable and supports both local and non-local multiplayer. 
It features a functional turn & team systems, unit mechanics, fully-featured RTS-style camera and a tile-based map with line-of-sight considerations.

## Authors
- [Filip](https://github.com/Filip-Rak) - Design, game systems, networking, UI, and most of the content.
- [Nopee](https://github.com/fakeNopee) - Made a few (very basic) unit models and provided moral support by being vaguely around.

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
    - **Choke points** are created naturally by rivers and bridges, encouraging deliberate movement and positioning.
    
  - ### Turn System

    Sightline uses a traditional, server-driven turn-based system built to support both local and online multiplayer. At the start of the game, turn order is randomized (with plans to support more refined methods in the future). Each player takes their turn in sequence, with game state updates synchronized across the network.

    The system currently supports:
    - **Fixed turn timers** - with the option to disable or expand to dynamic timers later.
    - **Automatic turn transitions** - turns advance when the timer expires or a player ends their turn.
    - **Multiplayer-safe logic** - all state changes are handled server-side and replicated to clients.
    - **Disconnection handling** - the game gracefully skips turns or reorders when a player drops.
    - **Manual turn skipping (disabled timer)** - for less strict games allowing players to take all the time they need.

    The turn system is designed with extensibility in mind, forming a solid base for future features like dynamic pacing or interrupt-based actions.

  - ### Team system
    Teams in Sightline are created dynamically at the start of each match based on player assignments. Each team tracks its own members, tile ownership, and score independently, allowing for both solo and cooperative gameplay structures.
    
    Key features include:
    - **Dynamic team generation** – teams are automatically created based on player configuration
    - **Tile control tracking** – each team keeps a list of tiles it controls, used for scoring and reinforcement logic
    - **Scoring system** – teams earn points each turn based on the value of controlled tiles
    - **Ownership updates** – tile ownership shifts during gameplay, with team state updated in real time
    - **Multiplayer synchronization** – team data is synced across the network for consistent state management
    
    This system supports future features like alliances, shared resources, or team-based objectives.

  - ### Unit Actions
  
    Each unit in Sightline is built around a modular action system. All actions inherit from a common base class, allowing flexible extension of unit behaviors. This structure makes it easy to define, reuse, and balance core mechanics like movement, attacks, and deployment.
    
    The action system supports:
    - **Action inheritance** – all actions derive from a base `Action` class, which provides shared behavior such as AP cost, cooldowns, and targeting logic.
    - **Specialized subclasses** – actions like `Action_Move`, `Action_Range_Attack`, and `Action_Spawn` implement specific logic while reusing shared structure.
    - **Per-unit configuration** – each unit has its own instance of action classes with unique parameters (e.g. range, damage, AP cost, cooldown).
    - **Cooldown and usage limits** – actions can be restricted by turn-based cooldowns or limited use per unit.
    - **Tile and unit highlighting** – the system integrates with the UI to visually guide the player toward valid targets and move options.
    
    This modular approach enables easy expansion and future addition of new action types, such as overwatch, repair, or area effects.

    - #### Movement
    
      Movement is implemented through a dedicated `Action_Move` class in combination with a custom `PathFinding` system. Rather than simple point-to-point moves, this system calculates valid paths based on terrain and action points using A* pathfinding.
    
      - **A\*-based logic** – paths are generated using a standard heuristic-based algorithm.
      - **Partial movement** – units can move even if the destination would exhaust remaining action points.
      - **Flexible design** – the system supports planned features like enemy zone-of-control checks and visibility-based restrictions.
    
      This system supports tactical depth by requiring players to think about not just where a unit can go, but what risks are involved in each step.
