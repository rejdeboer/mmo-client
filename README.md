# MMORPG Client (Work in progres)

This repository contains the source code for the client of a prototype MMO. It is built with the **Godot Engine** and features a high-performance networking and logic core written in **Rust** via **GDExtension**.

---

## Technical Highlights & Architecture

The client's architecture is designed to cleanly separate the high-level game logic (in GDScript) from the low-level, performance-critical networking and data processing (in Rust).

*   **Engine:** **Godot 4.x**
*   **Core Logic:** **Rust** via `godot-rust` (GDExtension)
*   **UI & Scene Management:** **GDScript**

The core principle is to **"let Rust handle the bytes, and let Godot handle the visuals."**

### Key Features:

*   **High-Performance Networking:** All UDP and WebSocket communication is handled by a "headless" Rust client library. This keeps the real-time networking off Godot's main thread, ensuring a smooth framerate.
*   **Safe, Decoupled Communication:** The GDExtension layer communicates with the pure Rust networking layer via thread-safe `tokio::mpsc` channels, creating a robust and clean boundary between the two worlds.
*   **Zero-Copy Deserialization:** Receives and parses **FlatBuffers** messages from the server. A dedicated parser translates the raw network buffers into safe, owned Rust structs before passing them to the Godot-facing logic, providing both performance and safety.
*   **Dynamic World Spawning:** Listens for `EntitySpawn` events from the server and dynamically creates and manages player and NPC nodes in the Godot scene tree.

---

## Project Structure

*   **/godot/globals:** Scenes and scripts that are initialized as Godot "Autoloads", which can be used across the whole project.
*   **/godot/game:** Scenes and scripts that manage code to display the world with its entities.
*   **/godot/tools:** Scripts that can be used by a developer to quickly start a client with a secure / unsecure connection.
*   **/rust/src/social:** The Rust source code for communicating with the WebSocket social server.
*   **/rust/src/game:** The Rust source code for sending and receiving messages from the game server using UDP.
