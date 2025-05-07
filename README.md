# Sightline 
A turn-based multiplayer strategy prototype with a modern military theme, built in Godot 4.

## Table of Contents

- [Features](#features)
  - [Camera](#camera)
  - [Map](#map)
  - [Turn System](#turn-system)
  - [Team System](#team-system)
  - [Unit Actions](#unit-actions)
  - [Game UI](#game-ui)
  - [Multiplayer](#multiplayer)
  - [Units](#units)
- [How to Play](#how-to-play)
  - [Game Rules](#game-rules)
  - [Controls](#controls)
  - [Local Multiplayer](#local-multiplayer)
  - [Non-Local Multiplayer](#non-local-multiplayer)
- [Installation](#installation)
- [Tech Stack](#tech-stack)
- [Code Structure](#code-structure)
- [Authors](#authors)
- [License](#license)


## Overview
**Sightline** is a prototype of a modern military-themed, turn-based multiplayer strategy game developed entirely in my free time as a personal hobby project. 
The main goal behind the project was to explore and learn the process of building larger-scale games - particularly focusing on networking, multiplayer systems, and working within the Godot 4 engine.

While the game is incomplete and relatively bare in terms of content and polish, it is fully playable and supports both local and non-local multiplayer. 
It features a functional turn & team systems, unit mechanics, fully-featured RTS-style camera and a tile-based map with line-of-sight considerations.

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
      
  - ### Game UI
    Sightline features a custom-built, context-sensitive user interface designed for turn-based strategy gameplay. The UI adapts to the current selection, provides quick access to key mechanics, and supports both player feedback and interaction in multiplayer sessions.
    
    Core features include:
    - **Contextual inspection panels** – separate panels display detailed stats and actions for selected units or tiles
    - **Turn info and timers** – current turn, player, and remaining time are always visible
    - **Unit action buttons** – available unit actions are presented with interactive tooltips and cooldown/status tracking
    - **Dynamic buy menu** – allows teams to deploy reinforcements based on spawn tiles and available points, sorted by category
    - **Score tracking** – live team score display in the UI, updated at the start of each turn
    - **Mouse interaction filtering** – raycast suppression when hovering UI elements ensures gameplay clarity
    - **Tooltip system** – delayed tooltips with contextual positioning for action buttons and unit abilities
    
    The interface is designed to be both informative and functional, helping players quickly interpret game state and execute actions.

  - ### Multiplayer
  
    Sightline supports both local and online multiplayer, with peer-to-peer communication handled via Godot’s high-level multiplayer API (ENet). Players can host or join games, with all essential gameplay systems (turns, units, tile control, UI updates) synchronized across the network.
    
    Multiplayer functionality includes:
    - **LAN/Direct IP hosting** – simple setup for hosting and joining matches.
    - **Networked turn system** – player turns are synchronized and tracked server-side.
    - **Real-time state updates** – unit actions, tile control, and player data are replicated across all clients.
    - **Basic disconnection handling** – dropped players are accounted for, and turn order adapts accordingly.
    
    The multiplayer system is functional but remains one of the rougher parts of the project — it’s split across multiple files and still lacks deeper abstraction or polish. Despite that, it provided valuable experience in building and troubleshooting real-time networking in Godot.

  - ### Units

    Sightline features a diverse roster of units organized into categories like Infantry and Vehicles, each with unique stats, abilities, and battlefield roles. The unit system is designed to be fully modular, with individual instances tracking their own action points, cooldowns, and health.
    
    Each unit is defined through two layers:
    - **Unit class** – tracks in-game state (AP, HP, cooldowns, position, player ownership)
    - **Unit properties** – defines static characteristics (actions, stats, category, modifiers)
    
    Key features include:
    - **Action point system** – units have limited actions per turn, affecting both movement and attacks.
    - **Custom loadouts** – each unit has its own set of actions (e.g., suppressive fire, AT rockets), instantiated from shared action classes.
    - **Stat-based combat** – units have AP/HE damage resistances and terrain-dependent defense modifiers.
    - **Transport compatibility** – infantry can be carried by capable vechicles (yet to be fully implemented).
    - **Vision system** – each unit has a defined sight range, which affects tactical awareness.
    - **Unit roles and categories** – units are grouped into roles (e.g., Motostrelki as light infantry, M2A3 Bradley IFV as heavy armor) with meaningful gameplay differences.
    
    Example units:
    - **Motostrelki** – flexible infantry with rifles and light RPGs.
    - **Panzergrenadiers** – well-equipped infantry with access to ATGMs and strong suppressive fire.
    - **HMMWV** – a fast recon vehicle with suppressive fire capability.
    - **BMP-2** – lightly armored IFV offering decent firepower against soft targets.
    - **M2A3 Bradley** – a durable IFV with autocannon support focusing on dealing with armored threats.
    
    This layered system makes it easy to add new units or rebalance existing ones, and supports a wide range of tactical scenarios.

## Tech Stack

Sightline is built entirely using free and open-source tools, with all gameplay logic and systems developed from scratch.

- **Engine:** [Godot 4.2.2 (stable)](https://godotengine.org/) – used for all gameplay, networking, UI, and rendering.
- **Language:** GDScript – core gameplay systems, UI, multiplayer logic, and AI pathfinding written in GDScript.
- **3D Models:** [Blender](https://www.blender.org/) – used for creating placeholder unit models.
- **Texturing:** [Substance Painter](https://substance3d.adobe.com/) – used to texture and bake the handful of models used in the prototype.
- **Multiplayer:** Godot High-Level Multiplayer API (ENet) – used for server-hosted peer communication, RPCs, and state sync.
  
## How to play
  ### Game Rules
  While there is currently no formal win condition, players compete to accumulate points and outmaneuver opponents through smart use of terrain and units.
  
  Core rules and mechanics:
  - **Turn-based play** – each player takes their turn in sequence; turns are either timed or manual depending on match setup.
  - **Point income** – every turn, each team gains 5 base points, used to deploy new units.
  - **Tile control** – certain tiles provide conquest points when controlled. A tile is considered "controlled" by the last team to have a unit visit it.
  - **Score accumulation** – at the end of each round (full turn cycle), all teams are awarded points based on the total value of tiles they control. These points are tracked on the leaderboard.
  - **Unit deployment** – reinforcements can be purchased and deployed at spawn points, provided the tile is under uncontested control.
  - **Spawn point contesting** – if an enemy team moves a unit onto a spawn point tile, it loses the spawn status forever.
  - **Combat** – players can only attack units belonging to opposing teams.
  
  ### Controls
  #### Camera Controls
  - **Move camera** – `W`, `A`, `S`, `D`.
  - **Rotate camera** – Hold `MMB` or `LCTRL` + mouse drag.
  - **Zoom camera** – Scroll wheel.
  - **Edge pan camera** – Move mouse to screen edges while holding `LSHIFT`.
  
  #### Gameplay Controls
  - **Select unit/tile** – Left Click.
  - **Use action (select target tile/unit)** – Right Click.
  - **Cancel current selection/action/buy menu** – `ESC` (in that order).
  
  #### UI Interaction
  - **Click buttons (e.g., End Turn, Actions, Buy Menu)** – Left Click.
  - **Hover for tooltip** – Hover over action buttons briefly.
  
  The interface is fully mouse-driven, with keyboard input primarily used for camera control and quick canceling.

  ### Local Multiplayer
  Sightline launches into a debug menu that allows for quick local multiplayer testing.
  
  Steps to play locally with two players:
  1. **Launch two instances** of the game.
  2. Remember to pick teams for both players (1-4), otherwise it will default to 1.
  3. In one instance, click the **"Host"** button — this becomes the game host.
  4. In the second instance, click the **"Join"** button — it will automatically connect to the host via default settings (no need to enter address or port).
  5. Both players should now appear in the player list.
  6. Either player can press **"Start Game"** to begin the match.
  
  Each player can select a **name** and **team** from the menu before starting.
  
  Want to test the game alone?  
  You can skip hosting entirely — just click **"Start Game"** in the main menu to launch a solo session.

  ### Non-Local Multiplayer
  To simulate a local network between remote machines, use a virtual LAN service such as [Radmin VPN](https://www.radmin-vpn.com/)
  
  Once all players are connected to the same virtual network:
  1. Have one player **Host** the game (just like in local play).
  2. Other players enter the **host’s virtual IP address** and click **Join**.
  3. Once everyone is connected, the game can be started from either instance.
  
  Note: Port forwarding is *not* required when using VPN tools like Radmin. However, performance and stability may vary depending on network quality.
  This is a workaround, not a production-grade online system - but it works well for testing and casual play.

## Installation

  There are two ways to run the game:
  
  ---
  
  ### Option 1: Download Executable
  
  Download `zip` from [Releases]() section.
  
  **To play:**
  1. Extract the zip and run `Sightline.exe` (keep the folder structure intact).
  2. The game will launch directly into the debug menu for immediate local or LAN play.
  
  ---
  
  ### Option 2: Run from Source (Godot)
  
  If you prefer working with the raw project files.
  
  **Requirements:**
  - [Godot 4](https://godotengine.org/download/)
  > The project was developed in Godot 4.2.2, but it should run fine in any Godot 4.x version. If you encounter compatibility issues, try using the original 4.2.2 release.
  
  **Steps:**
  1. Clone or fork this repository.
  2. Open the project folder in Godot.
  3. Press **F5** or click **Run Project** to launch.
  
  This will start the debug lobby where you can immediately test the game locally, solo, or via LAN (see [How to Play](#how-to-play) for multiplayer setup).
  
  > Note: The project was built as a learning prototype. Some features may be incomplete or unpolished, and a mouse is recommended for full control of the camera and UI.

## Code Structure
Sightline's codebase is organized around modular systems. Distinct scripts contribute to the overall architecture as follows:

- **Core Game Systems**
  - `GameManager.gd`, `TurnManager.gd`, `TeamManager.gd`, `StateMachine.gd`, `PlayerManager.gd`
  - Handle global game flow, player data, turn logic, and team coordination

- **Units & Combat**
  - `Unit.gd`, `UnitProperties.gd`, `unit_label3D.gd`, `unit_label_content.gd`
  - Define unit stats, actions, visual labeling, and in-game behavior

- **Tiles & Map Logic**
  - `Tile.gd`, `TileProperties.gd`, `MapLoader.gd`, `tile_label_3d.gd`
  - Manage map generation, tile properties (LOS, defense), and in-game labeling

- **Camera & Input**
  - `PlayerCamera.gd`, `DebugCamera.gd`, `MouseModeManager.gd`
  - Provide RTS-style camera control and input modes (inspection, action, etc.)

- **UI & Interaction**
  - `GameUI.gd`, `Action_Tooltip.gd`, `HighlightManager.gd`
  - Handle the user interface, tooltips, dynamic highlights, and contextual elements

- **Networking**
  - `Network.gd`, `DebugLobby.gd`
  - Set up client/server logic, handle connection/disconnection, and player data sync

- **Utilities & Support**
  - `Utility.gd`, `PathFinding.gd`
  - Contain helpers for map traversal, enemy detection, and general-purpose logic

## Authors
- [Filip](https://github.com/Filip-Rak) - Design, game systems, networking, UI, and most of the content.
- [Nopee](https://github.com/fakeNopee) - Made unit and tile models, as well as provided moral support by being vaguely around.

## License
This project is licensed under the **Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)** license.

That means you're free to:
- Look at the code and learn from it.
- Fork it, experiment, remix, or build on it non-commercially.
- Share it with attribution.

But **you may not**:
- Use it for commercial purposes without permission.
- Remove or falsify credit to the original authors.

See the full license [here](https://creativecommons.org/licenses/by-nc/4.0/).
