% Traffic / Crowd Flow Simulation with Cellular Automata 
% Clinton McKay
% May 9, 2013

# Outline
## Introduction
## Method
  - Traffic Flow one- and two-lane freeway
  - Crowd Flow during an evacuation.

## Verification
## Analysis
## Interpretation
## Sources

# Introduction
Investigate the use of Cellular Automata to simulate traffic and crowd flow within a system. The target language will be the agent-based language NetLogo.

# Traffic Simulations

Cellular Automata based traffic simulations.

# Method Single-Lane
  - Traffic flow on a single lane freeway by Kai Nagel of length $L$ with periodic boundaries. 
    1. Accelerate the vehicle if there is a gap in front of the vehicle that is larger than its velocity. $v = v + 1$
    2. Slow down a vehicle that has a velocity that is greater than the gap in front of it. Match its velocity to the gap size. 
    3. People can't drive. Apply random fluctuations that either increment or decrement in the vehicle velocities by either accelerating or braking. 
    4. Update the positions of the vehicles in the system.

# Analysis Single-Lane
  - Live demo and initial conditions. 
    0. World width $w = 63$
    1. Number of vehicles $h = 15$
    2. Maximum velocity $v_max = 6$
    3. Braking $p_b = 0.10$ and accelerating $p_a = 0.20$

# Verification 
  - Comparison to physics traffic simulation model. 

# Method Two-lane
  - Two-lane traffic flow. Takes the previous algorithm and adds an additional sub step. 
    1. Check neighboring lanes for larger gaps. If a larger gap exists then with a probability $p$ switch to that lane. The motion will only be lateral, the velocity doesn't affect the vehicle until the next step.
    2. Apply the previous algorithm. 

# Analysis Dual Lane
  - Live demo and initial conditions. 
    0. World width $w = 64$
    1. Number of vehicles $h = 15$
    2. Maximum velocity $v_max = 6$
    3. Braking $p_b = 0.10$ and accelerating $p_a = 0.20$
    4. Lane change probability $p_l = 0.3$. 

# Crowd Flow

Simulations of crowd exiting room. 

# Method
  - Nishinari's foraging ant and pedestrian algorithm.
    1. For each pedestrian, construct a set of weights $p_{ij}$ that can be used to select potential future positions. The formula is:

    \begin{align*}
      p_{ij} = e^{k_DD_{ij}}e^{k_SS_{ij}}P_I(i, j) *x_{ij} 
    \end{align*}

    2. After constructing the weights, use them to sample the next location of the pedestrian. Move to that location. 
    3. After moving the pedestrians. Backtrack pedestrians that have landed on the same site to their old positions. Sample a pedestrian to stay at the new location.
    4. Modify the value of $D_{ij}$ based on the pedestrians above it. 
  
# Verification 
  - Unable to verify the algorithm it is not performing correctly. 

# Sources
  1. _A cellular automaton model for freeway traffic_ Kai Nagel and Michael Schreckenberg
  2. _Two lane traffic simulations using cellular automata_ M.Rickert, K.Nagel, M.Schreckenberg, and  A.Latour
  3. _Modelling of self-driven particles: Foragin ants and pedestrians_ Katsuhiro Nishinari, Ken Sugawara, Toshiy Kazama, Andreas Schadschnieder, and Debashis Chowdhury. 

