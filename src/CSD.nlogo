; boundary? -> if the patch is a boundary
; sink?     -> if the patch is a sink
; source?   -> if the patch is a source
; sink-distance -> the distance to the sink
; previous-patch-x -> the x position of the prvious patch
; previous-patch-y -> the y position of the prvious patch
patches-own [boundary? sink? source? sink-distance pheremone-level]
turtles-own [previous-patch target-patch previous-patch-x previous-patch-y]

; boundary-pcolor -> the default bounday color
; sink-color      -> the default sink color
; source-color    -> the default source color
; path-color      -> the default path color
; boundary-elvation -> the default boundary elevation
; PROB_MAX -> a probability constant. 
globals [boundary-pcolor sink-pcolor source-pcolor path-pcolor original-people-count PROB_MAX]

extensions [table] ; essentially a dictionary. 

to square-room
  setup-patches
  
  ask patches [
     if (pxcor = max-pxcor) or (pxcor = min-pxcor)
     [
       enable-boundary
     ]
     
     if (pycor = max-pycor) or (pycor = min-pycor)
     [
       enable-boundary
     ]
     
    if (pxcor = int(max-pxcor / 2)) and (pycor = 0)
    [
      disable-boundary
      enable-sink 
    ]
    
    if(pxcor = 1 and pycor = max-pycor - 1)
    [
      disable-boundary
      enable-source 
    ]
    
    if(pxcor = max-pxcor - 1 and pycor = max-pycor - 1)
    [
      disable-boundary
      enable-source 
    ]
    
  ]
  
  ask patches [ paint-paths set-distances ]
end

to setup-default
  set default_export_path_name "../patches/CSD_Custom_World.csv"
  set default_import_path_name "../patches/CSD_Default_World.csv"
  
  set-patch-size ptch-size
  
  setup-globals
  
  import-csd-world
end

to setup-globals
  set sink-elevation 1.0E-4
  set source-elevation 1
  set boundary-elevation 1000
  set PROB_MAX 1
  setup-colors
  ask turtles [ die ] ; Kill all turtles if any
  
  reset-ticks
end

; 
to setup-blank
  setup-patches
  ask patches [paint-paths]
  ask patches [set-distances]
  
  set default_export_path_name "../patches/CSD_Default_World.csv"
  set default_import_path_name "../patches/Blank_World.csv"
end

to setup-patches
  ask patches
  [
   set boundary? false
   set sink? false
   set source? false
   set sink-distance 0 
  ]
end

to set-distances
  set sink-distance sink-elevation
  if source? = True [
   set sink-distance source-elevation;
  ]
  if boundary? = True [
   set sink-distance boundary-elevation 
  ]
end


to import-csd-world
  import-world default_import_path_name
  
  set-patch-size ptch-size
end

to export-csd-world
  export-world default_export_path_name
end
  
to setup-colors
  set boundary-pcolor 130
  set sink-pcolor 11
  set source-pcolor 19
  set path-pcolor 15
end

to black-as-boundary ;; goes through and converts all of the black tiles to boundarys (aka undifussable values.)
  ask patches [
    if pcolor = 0 [ 
      set boundary? True
      set boundary-pcolor 130
    ]
  ]
end

to clear-sinks-sources
  ask patches [
    set sink? False
    set source? False
  ]
end

;; Sets all of the white cells as traversable paths. 
to white-as-path
  ask patches [
    if pcolor = 9.9 [
      set boundary? False
      set pcolor source-pcolor 
    ]
  ]
end

to paint-paths
  ;boundary-pcolor sink-pcolor source-pcolor path-pcolor
  if (boundary? = False) and (sink? = False) and (source? = False) [
    set pcolor path-pcolor
  ]
  if boundary? [ set pcolor boundary-pcolor ]
  if sink? [ set pcolor sink-pcolor ]
  if source? [ set pcolor source-pcolor ]
end

;-------------------- SINK
to enable-sink
  set sink? True
  set source? False
  set pcolor sink-pcolor ; set to source pcolor
end

to disable-sink
  set sink? False
  set pcolor path-pcolor ; set to the default path color
end
;--------------------

;-------------------- SOURCE
to enable-source
  set sink? False
  set source? True
  set pcolor source-pcolor ; set to source pcolor
end

to disable-source
  set source? False
  set pcolor path-pcolor ; set to the default path color
end
;--------------------

;-------------------- BOUNDARY
to enable-boundary
  set boundary?  True
  set source? False
  set sink? False
  set sink-distance boundary-elevation
  set pcolor boundary-pcolor
end

to disable-boundary
  set boundary? False
  set source? False
  set sink? False
  set sink-distance sink-elevation
  set pcolor path-pcolor
end
;--------------------

to add-sink
  while [mouse-down?] [
    ask patch mouse-xcor mouse-ycor [
      if not boundary? [
        ifelse sink? = True [
          disable-sink
        ] [
          enable-sink
        ]
      ]
    ]
  ]
  display
end

to add-source
  while [mouse-down?] [
    ask patch mouse-xcor mouse-ycor [
      if not boundary? [
        ifelse source? = True [
          disable-source
        ] [
          enable-source
        ]
      ]
    ]
  ]
  display
end

to add-boundary
  while [mouse-down?] [
    ask patch mouse-xcor mouse-ycor [
      ifelse not boundary? [
        enable-boundary
      ] [
        disable-boundary
      ]
    ]
  ]
  display
end

to add-turtle
  while [mouse-down?] [
    create-turtles 1
  ]
  ask turtles [
    move-to one-of patches
  ]
end

to spawn-turtles
  set-default-shape turtles "person"
  
  ; count the number of placeable patches. 
  let mx-pssble count patches with [not boundary?]
  let mx-ppl int mx-pssble * fill-percent
  
  let num-spawned 0
  ask patches [
    if (num-spawned < mx-ppl) or fill-room [
      if boundary? = False [
        sprout 1
        set num-spawned num-spawned + 1
      ]
    ]
  ]
end
   

;; Diffusion Happens Here
to diffuse-patches
  ask patches [diffuse-pcolor diffuse-dist]
end

to diffuse-dist
  let ngbrs neighbors4
  let wghts []
  if (boundary? = False) and (sink? = False) and (source? = False) [ 
    ask ngbrs [
      if (boundary? = False) [
        set wghts fput sink-distance wghts ; fput appends to a list
      ] 
    ]
    set sink-distance mean wghts
  ]
end

to diffuse-pcolor
  let ngbrs neighbors4
  let wghts []
  if (boundary? = False) and (sink? = False) and (source? = False) [ 
    ask ngbrs [
      if boundary? = False [
        set wghts fput pcolor wghts
      ] 
    ]
    set pcolor mean wghts
  ]
end

to diffuse-pheremones
  let ngbrs neighbors4
  let wghts []
  if (boundary? = False) and (sink? = False) and (source? = False) [ 
    ask ngbrs [
      if boundary? = False [
        set wghts fput pheremone-level wghts
      ] 
    ]
    set pheremone-level mean wghts
  ]
end

;;--------------------------------------- SIMULATION FUNCTIONS ---------------------------------------------------;;
;;--------------------------------------- SIMULATION FUNCTIONS ---------------------------------------------------;;
;;--------------------------------------- SIMULATION FUNCTIONS ---------------------------------------------------;;

;; Update and turtle motions
to update
  ask turtles [ set previous-patch patch-here]
  ask patches [ 
    diffuse-pheremones ; apply the default pheremone diffusion rate. 
    apply-pheremones ; set phereome level to one if there is a person 
    decay-pheremones  
  ] 
  ask turtles [ move-turtle ]
  ask turtles [ if (sink? = True) [ die ] ]
  ask turtles [ ; This part here is part of the topology mentioned that forces movement towards the doors. aka the K_s value. 
    set previous-patch patch-here ; stor
    let xcor_0 xcor
    let ycor_0 ycor
    downhill sink-distance
    if (count turtles-at 0 0) >= 2 [
      set xcor xcor_0
      set ycor ycor_0
    ]
  ]
  ask turtles [ if (sink? = True) [ die ] ]
  
  tick
end

to apply-pheremones
  let person one-of turtles-on patch-at 0 0
  
  if person != nobody [ set pheremone-level 100 ]
end

to decay-pheremones
  let r random-float PROB_MAX
  
  if r < pheremone-decay-prob
  [
    if pheremone-level > 0 [ set pheremone-level pheremone-level - 1 ]
  ]
end

; Implement the motion algorithm as described in 
; Modelling of self-driven particles: Foraging ants and pedestrians -- Katsuhiro Nishinari,  Ken Sugawara, Toshiya Kazama, Andreas Schadschneider, Debashish Chowdhury
to move-turtle
  let target nobody
  ; loop through the neighbor patches for each turtle. 
  let ngbrs neighbors
  ;print ngbrs
  let mxm_prb 0
  let crn_prb 0
  if (boundary? = False) and (sink? = False) and (source? = False) [ 
    ; first loop to calculate the sum of the weights
    ask ngbrs [
      if (boundary? = False) and (not sink?) [
        let xphi 1
        let person one-of turtles-on patch-at 0 0
        if person != nobody [ set xphi 0 ] ; cell cannot be accessed. force probability to zero. 
        
        let D_ij pheremone-level ; set D_ij to the pheremone level of the patch
        
        let A exp(D_ij * panic-level) ; D_ij * k_D (k_D := panic level)
        let B exp( 1 / sink-distance) ; inversly proportial to the distance. k_S is set to one for this problem
        
        let P_ij A * B * xphi
        
        set mxm_prb mxm_prb + P_ij
      ]
    ]
    ; next loop randomly choose a patch to jump to . 
    let r random-float mxm_prb
    ask ngbrs [
      if (boundary? = False) [
        let xphi 1
        let person one-of turtles-on patch-at 0 0
        if person != nobody [ set xphi 0 ] ; cell cannot be accessed. force probability to zero. 
        
        let D_ij pheremone-level ; set D_ij to the pheremone level of the patch
        
        let A exp(D_ij * panic-level) ; D_ij * k_D (k_D := panic level)
        let B exp(12 / sink-distance) ; inversly proportial to the distance. k_S is set to one for this problem
        
        let P_ij A * B * xphi
        
        ; found the patch to move to. 
        if ( r > crn_prb ) and ( r < crn_prb + P_ij ) [
          set target patch-at 0 0
        ]
        
        set crn_prb crn_prb + P_ij
      ]
    ]
    
    set target-patch target
    
    ; move person to target patch if appropriate. 
    if target-patch != nobody 
    [
      face target-patch
      move-to target-patch
    ]
  ]
end









  
@#$#@#$#@
GRAPHICS-WINDOW
10
10
405
646
-1
-1
11.0
1
10
1
1
1
0
0
0
1
0
34
0
54
1
1
1
ticks
30.0

BUTTON
803
436
938
469
2. Add Source
add-source
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1074
10
1239
43
Setup Default World
setup-default
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
804
479
1020
512
Set-Elevations and Paint Paths
paint-paths\nset-distances
NIL
1
T
PATCH
NIL
NIL
NIL
NIL
1

BUTTON
853
72
989
105
Import CSD -->
import-csd-world
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
990
106
1239
166
default_export_path_name
../patches/CSD_Default_World.csv
1
0
String

BUTTON
809
133
988
166
Export World As ---->
export-csd-world
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
990
45
1239
105
default_import_path_name
../patches/CSD_Default_World.csv
1
0
String

BUTTON
804
514
1021
547
3. Diffuse
diffuse-patches
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
803
646
888
679
Update
update
T
1
T
OBSERVER
NIL
U
NIL
NIL
0

BUTTON
1176
610
1309
643
Spawn People
spawn-turtles\nset original-people-count count turtles
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
802
365
936
398
2. Add Boundary
add-boundary
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
882
12
986
45
Erase World
setup-blank
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
1296
273
1451
333
ptch-size
11
1
0
Number

BUTTON
1180
273
1294
306
Set Patch Size
set-patch-size ptch-size\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
1296
335
1451
395
sink-elevation
1.0E-4
1
0
Number

INPUTBOX
1296
395
1451
455
source-elevation
1
1
0
Number

SLIDER
803
684
1162
717
panic-level
panic-level
0
10
0
1
1
NIL
HORIZONTAL

SLIDER
803
726
1161
759
pheremone-decay-prob
pheremone-decay-prob
0
PROB_MAX
0
PROB_MAX / 100
1
NIL
HORIZONTAL

BUTTON
802
327
943
360
1. Setup Variables
setup-globals
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1176
648
1498
681
fill-percent
fill-percent
0.0
PROB_MAX
0.4
PROB_MAX / 100
1
NIL
HORIZONTAL

SWITCH
1176
683
1499
716
fill-room
fill-room
0
1
-1000

INPUTBOX
1296
456
1451
516
boundary-elevation
1000
1
0
Number

BUTTON
803
401
937
434
2. Add Sink
add-sink
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1315
601
1418
646
Starting Count
count turtles
17
1
11

BUTTON
1175
546
1309
607
Reset
reset-ticks\nsetup-globals\nclear-turtles\nclear-all-plots
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1592
20
2019
237
Flow
ticks
People
0.0
10.0
0.0
10.0
true
false
"" ";set-plot-y-range 0 int((original-people-count - count turtles) / (ticks + 1) + 1)"
PENS
"Flux" 1.0 0 -16777216 true "" "plot (original-people-count - count turtles) / (ticks + 1)"

BUTTON
3148
94
3226
128
useless
NIL
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1425
600
1528
645
Starting Count
original-people-count
17
1
11

MONITOR
1536
599
1610
644
Total Flux
(original-people-count - count turtles) / ticks
4
1
11

@#$#@#$#@
## WHAT IS IT?

Simulates crowd flow using cellular automata. 

## HOW IT WORKS

As of now the rules have yet to be implemented. The only rule is that if a patch contains a turtle then other turtles cannot access that patch.

## HOW TO USE IT

  1. Click on the _Import CSD_ button. If you wish you can choose which CSD to import, but it is best use the default. 

  2. Click the _Setup_ button.

  3. Next click the _Update_ button

  4. Add turtles by clicking the _Spawn Turtles_ button. 
  
  5. You can modify the boundaries, sources, and sinks of the system if you wish with the _Add Sink_, _Add Source_, and _Add Boundary_ buttons. 

  6. Once you have modified the layout make sure to _Diffuse_ the model so that agents can find the sinks. 

## THINGS TO NOTICE

Notice how much fun this is?

## THINGS TO TRY

None yet. I plan on allowing users to import images in the future. 

## EXTENDING THE MODEL

Add the cellular automation rules. 

## NETLOGO FEATURES

None founded yet. 

## RELATED MODELS

Look at the Game of Life models. 

## CREDITS AND REFERENCES

The insperation for this model if from "Particle hopping models and traffic flow theory" by Kai Nagel. 

Will also be using the book "Introduction to Modern Traffic Flow Theory and Control" by Boris S. Kerner.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.5
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
