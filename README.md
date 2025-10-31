# Information Propagation through Swarm Intelligence in Complex Bloodstream-like Environments
Project for Design of Multi-Agent Systems

Authors:
Dorin-Vlad Udrea · Samuel Dos Santos Stork · Óscar Ferrer Domingo · Martijn Schippers

Overview

This repository contains the Godot-based simulation framework used to evaluate a decentralised swarm-intelligence architecture inspired by biomedical nanorobotics. The system models nanobot-like agents navigating complex, partially observable environments that resemble microvascular networks.

Agents operate without global knowledge, using only:

Local perception

Short-range state communication

Finite-state machine (FSM) behaviour

Occlusion and density-aware decision logic

The simulation allows benchmarking of multiple strategies for information propagation and collective navigation in constrained environments.

Abstract

Swarm intelligence offers a scalable framework for coordinating populations of simple agents, with direct relevance to future biomedical nanorobotic systems. This project investigates a decentralised finite-state machine with occlusion logic (FSM-OL) for swarm navigation in bloodstream-like environments. Each agent has a limited sensing range and communicates only locally. Agents switch between seven behavioural states, balancing exploration and exploitation through density-driven repulsion and dynamic sub-goal formation at visibility frontiers.


Features

Godot-engine simulation of bloodstream-like environments modeled as mazes

Modular FSM controller with occlusion-aware logic

Beacon-based dynamic sub-goal propagation

Real-time agent visualisation and telemetry

Configurable agent counts, sensing ranges, and map layouts

Baselines for comparative evaluation (RW, RW-S)
