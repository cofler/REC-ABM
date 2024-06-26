globals [
  infinity         ; used to represent the distance between two turtles with no path between them

  prob-of-interaction
  rewiring-probability

  number-rewired                       ; number of edges that have been rewired
  users-counter
  energy-per-kw
  init-install-cost
  install-cost-per-kw
  ITC
  period
  year
  month
  e-cost
  ro
  ir
  average-consumption
  AWh
  prev-kw

  ; REC variables

  en-quota
  cost-quota
  return
  recs-counter

  tot-quotas-list


]

breed [ users user ]
breed [ RECs REC ]


users-own [
  ;simi
  id
  com-id
  age
  income
  education
  ethnicity
  house-size
  housing-condition
  Q
  AW
  CS
  ; PC
  O
  AB
  PG
  PM
  T
  AF
  Pb-install
  Pb-mbs
  Pb-maint
  P-emi
  NPV-b
  NPV-l
  PInv
  NPV-rec
  potential-REC-id
  made-choice
  made-choice-last-time
  see-change-by-other
]

RECs-own [
  tot-quotas ; quotas for each project
  subscribers ; subscribers for each project
  REC-id
]

links-own [
  new-link
  simi;
]






;;;;;;;;;;;;;;;;;;;;;;
;; Setup Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;


to setup
  clear-all
  reset-ticks


  ; set the global variables
  set infinity 99999      ; this is an arbitrary choice for a large number
  set number-rewired 0    ; initial count of rewired edges
  set users-counter 0
  set recs-counter 0
  set rewiring-probability 0.5
  set prob-of-interaction 0.5
  set energy-per-kw 107.1 ;
  set prev-kw 0

  set e-cost 0.2360 ;
  set average-consumption 976 ;
  set ro 0.05 ;
  set init-install-cost 1600 ;
  set ITC [0.70 0.65 0.60 0.55 0.40 0.35 0.30 0.25 0.20 0.15] ;
  set period [0 1 2 3 4 5 6 7 8 9]
  set install-cost-per-kw [1600]
  foreach period [ i ->  set install-cost-per-kw lput (item i install-cost-per-kw  * (1 - 0.026)) install-cost-per-kw]
  set year item 0 period
  set month 1
  set ir 0.005109
  set en-quota 275
  set cost-quota 1000
  set tot-quotas-list n-values 4 [ 1000 ]
  set AWh 0.6

  create-RECs num-RECs
  [
    set REC-id recs-counter
    set tot-quotas item REC-id tot-quotas-list
    set subscribers 0

    set recs-counter recs-counter + 1
  ]

  create-users num-users
  [
    set shape "person"
    set color blue
    set size 1.5
    set label-color blue - 2
    setxy random-xcor random-ycor
    set id users-counter
    set com-id infinity
    set age 0
    let r random-float 100
    ifelse r > 16.8 and r <= 30.3
      [ set age 1 ]
      [ ifelse r > 30.3 and r <= 46.2
         [ set age 2 ]
         [ ifelse r > 46.2 and r <= 65.1
            [ set age 3 ]
            [ ifelse r > 65.1 and r <= 80.5
               [ set age 4 ]
               [ if r > 80.5
                 [ set age 5 ]
               ]
            ]
         ]
      ]


    set income 0
    let r2 random-float 100
    ifelse r2 > 13.1 and r2 <= 29.4
      [ set income 1 ]
      [ ifelse r2 > 29.4 and r2 <= 50.5
         [ set income 2 ]
         [ ifelse r2 > 50.5 and r2 <= 75.8
            [ set income 3 ]
            [ if r2 > 75.8
              [ set income 4 ]
            ]
         ]
      ]
    set education 0
    let r0 random-float 100
    ifelse r0 > 6.18 and r0 <= 25.27
      [ set education 1 ]
      [ ifelse r0 > 25.27 and r0 <= 53.53
         [ set education 2 ]
         [ ifelse r0 > 53.53 and r0 <= 88.61
            [ set education 3 ]
            [ ifelse r0 > 88.61 and r0 <= 91.85
              [ set education 4 ]
              [ if r0 > 91.85
                 [ set education 5 ]
              ]
            ]
         ]
      ]

    set ethnicity 0
    let r1 random-float 100
    ifelse r1 > 93.70 and r1 <= 95.74
      [ set ethnicity 1 ]
      [ ifelse r1 > 95.74 and r1 <= 96.78
         [ set ethnicity 2 ]
         [ ifelse r1 > 96.78 and r1 <= 97.48
            [ set ethnicity 3 ]
            [ ifelse r1 > 97.47 and r1 <= 98.07
              [ set ethnicity 4 ]
              [ ifelse r1 > 98.07 and r1 <= 98.53
                 [ set ethnicity 5 ]
                 [ if r1 > 98.53 and r1 <= 98.98
                    [ set ethnicity 6 ]
                 ]
              ]
            ]

         ]
      ]
    set house-size 1
    let r3 random-float 100
    ifelse r3 > 38 and r0 <= 65.6
      [ set house-size 2 ]
      [ ifelse r3 > 65.6 and r3 <= 81.3
         [ set house-size 3 ]
         [ ifelse r3 > 81.3 and r3 <= 94.9
            [ set house-size 4 ]
            [ ifelse r3 > 94.9 and r3 <= 98.8
              [ set house-size 5 ]
              [ if r3 > 98.8
                 [ set house-size 6 ]
              ]
            ]
         ]
      ]

    set Q house-size * average-consumption
    set AW random-float 1 * (1 + education) / 6
    set users-counter users-counter + 1
    set CS false
    set O random-float 1
    let aux random-float 100
    set housing-condition 0
    ifelse aux > 30.3 and aux <= 71.7
      [ set housing-condition 1 ]
      [ if aux > 71.7
        [ set housing-condition 2 ]
      ]
    set AB random-float 1 * (age + 1) / 6
    set AF random-float 1 * (income + 1) / 5
    set T random 4
    ifelse T = 1
     [ set PG 0
        set PM 0.005
        set PInv -0.02]
     [ ifelse T = 2
      [ set PG 0.026
        set PM 0.0025
        set PInv 0.02 ]
      [ ifelse T = 3
        [ set PG 0.033
          set PM 0.0015
          set PInv 0.06  ]
        [ if T = 4
          [ set PG 0.05
            set PM 0 set
            PInv 0.08  ]
        ]
      ]
     ]
    ifelse xcor < 0 and ycor > 0
    [ set potential-REC-id 0 ]
    [ ifelse xcor > 0 and ycor > 0
      [ set potential-REC-id 1 ]
      [ ifelse xcor < 0 and ycor < 0
        [ set potential-REC-id 2 ]
        [ set potential-REC-id 3 ]
      ]
    ]
    set made-choice 0


  ]

  wire-users-lattice


end

;;;;;;;;;;;;;;;;;;;;;
;; Main Procedures ;;
;;;;;;;;;;;;;;;;;;;;;

to go


  rewire-all
  set-links-weights
  social-influence
  financial-assessment
  consumer-decision
  set month month + 1
  if month > 12
      [ set year year + 1
        set month 1       ]
  if year = 10 [stop]
  tick

end


to set-links-weights
  ask links [
    set simi 1 - abs([age] of end1 - [age] of end2) / 20 - abs([income] of end1
      - [income] of end2) / 16 - abs([education] of end1 - [education] of end2) / 20

    if [ethnicity] of end1 != [ethnicity] of end2
    [ set simi simi - 0.25  ]
  ]
end

to-report get-links-simis
  report sum[new-link] of links
end

to-report get-users-AW
  report sum[AW] of users
end

to-report get-subscribers
  report sum[subscribers] of RECs
end

to-report get-PVadopters
  report count users with [made-choice = 2 or made-choice = 3 ]
end



to-report get-quotas
  report sum[tot-quotas] of RECs
end

to-report get-tot-kw
  let tot-kw 0
  ask users[
  if made-choice != 0
    [ set tot-kw tot-kw + Q / energy-per-kw ]
  ]
  let installed-kw tot-kw - prev-kw
  set prev-kw tot-kw
  report installed-kw
end

to-report get-visual-influence
  report sum[see-change-by-other] of users
end

to-report get-choices-made
  report sum[made-choice-last-time] of users
end


; sub-model 1 updates
to social-influence
  ask users[

    ifelse made-choice = 0 [
    let neighbors-others users in-radius 4
    set see-change-by-other sum [ made-choice-last-time ] of neighbors-others with [ housing-condition = 0 and ( made-choice = 1 or made-choice = 2 ) ]
    set AW AW * ( 1 + see-change-by-other / 100 )
    ]
    [ set see-change-by-other 0 ]


    ; update CS
    if AW > random-float 1 and not CS [
      set AW AW + 0.1
      set CS true
    ]

    if random-float 1 < prob-of-interaction
    [
      ; update AW
      let temp AW
      ask my-links [
         if new-link = 1
         [
          set temp temp + simi * [AW] of other-end / 100
         ]
      ]
      set AW temp
    ]

    if AW > 1 [ set AW 1 ]

    ; update PC
    ; let temp2 PC
    ; ask my-links [
    ;   set temp2 temp2 + simi * (1 - [PC] of other-end ) / 100
    ; ]
    ; set PC temp2

  ]
end

; submodel 2 updates
to financial-assessment

  ask users [

  ; assessment - buying rooftop PV through up-front cash payment
  set Pb-install ( Q / energy-per-kw * item year install-cost-per-kw * (1 - item year ITC) )

  let Pb-mbs-list [ 0 ]

  foreach (range 1 25) [ tt ->  set Pb-mbs-list lput ((( 1 + PG ) / ( 1 + ro ) ) ^ ( tt - 1 )) Pb-mbs-list]
    set Pb-mbs-list (map * (n-values length Pb-mbs-list [12 * Q * e-cost]) Pb-mbs-list)
  set Pb-mbs sum Pb-mbs-list

  set Pb-maint 25 * PM * Pb-install

  set NPV-b Pb-mbs - ( Pb-install + Pb-maint )

  ; assessment - buying rooftop PV through solar loan - assuming monthly 10-year loans
  let N 120 ; number of payments

  let M-emi Pb-install * ir * ( 1 + ir ) ^ N / ( ( 1 + ir ) ^ N - 1 )

  let P-emi-list [ 0 ]
  foreach (range 1 10) [ tt ->  set P-emi-list lput (1 / ( 1 + ro ) ^ ( tt - 1 )) P-emi-list]
    set P-emi-list (map * (n-values length P-emi-list [12 * M-emi]) P-emi-list)
  set P-emi sum P-emi-list

  set NPV-l Pb-mbs - ( P-emi + Pb-maint )

  let P-returns ( 1 + PInv ) * ceiling Q / en-quota

  let disc-list [ 0 ]
  foreach (range 1 25) [ tt ->  set disc-list lput (1 / ( 1 + ro ) ^ ( tt - 1 )) disc-list]
  let disc sum disc-list

  set NPV-rec P-returns * disc
  ]

end


; submodel 3 - consumer agent decision
to consumer-decision

  ask users [

    if made-choice-last-time = 1 [set made-choice-last-time 0 ]

    if AW > AWh and made-choice = 0 and AF > random-float 1
    [ ifelse housing-condition != 0 ; renters and apartment-owners checks NPVs for RECs and normal utility electricity at first
      [ let choice 0
        if NPV-rec > 0
        [ ask RECS [ if ( REC-id = ( [potential-REC-id] of myself ) and tot-quotas > ceiling ( [Q] of myself / en-quota ) )
                     [ set tot-quotas tot-quotas - ceiling ( [Q] of myself / en-quota )
                       set subscribers subscribers + 1
                       set choice 1
                     ]
                   ]
        ]
        set made-choice choice
      ]
      [ ; let's deal now with owners
      let choice 0
      if NPV-rec > 0 and NPV-b <= 0 and NPV-l <= 0 [set choice 1 ]
      if NPV-rec <= 0 and NPV-b > 0 and NPV-l <= 0 [set choice 2 ]
      if NPV-rec <= 0 and NPV-b <= 0 and NPV-l > 0 [set choice 3 ]
      if choice = 0
        [
          ifelse NPV-b > 0 and NPV-l > 0 and ( NPV-b > NPV-rec and NPV-l > NPV-rec )
          [ ifelse NPV-b > NPV-l [ set choice 2 ] [ set choice 3 ]  ]
          [ let r random-float 1
            ifelse r < O
            [ ifelse NPV-b > 0 [ set choice 2 ] [ set choice 3 ]  ]
            [ ifelse NPV-b > 0
              [ ifelse NPV-rec > NPV-b [ set choice 1 ] [ set choice 2 ]  ]
              [ ifelse NPV-rec > NPV-l [ set choice 1 ] [ set choice 3 ]  ]
            ]
          ]

          let r2 random-float 1
          if r2 > AB and ( choice = 2 or choice = 3 ) [ set choice 1 ]
        ]

      let aux 0
      if choice = 1
        [ ask RECS [ if ( REC-id = ( [potential-REC-id] of myself ) and tot-quotas > ceiling ( [Q] of myself / en-quota ) )
                     [ set tot-quotas tot-quotas - ceiling ( [Q] of myself / en-quota )
                       set subscribers subscribers + 1
                       set aux 1
                     ]

                   ]
          set choice aux
        ]

       set made-choice choice

      ]
       if made-choice != 0 [set made-choice-last-time 1 ]
    ]
    if made-choice = 1 and potential-REC-id = 0 [set color red]
    if made-choice = 1 and potential-REC-id = 1 [set color green]
    if made-choice = 1 and potential-REC-id = 2 [set color white]
    if made-choice = 1 and potential-REC-id = 3 [set color violet]


  ]



end




to rewire-all

    ; ask each link to maybe rewire, according to the rewiring-probability
    ask links [
     ifelse random-float 1 < rewiring-probability [
      rewire-me
     ]
     [ set new-link 0 ]
    ]

    ;ask links [  set new-link 1   ]

  update-plots
end

to rewire-me ; user procedure
  ; node-A remains the same
  let node-A end1
  if random-float 1 > 0.5 [ set node-A end2 ]
  ; as long as A is not connected to everybody
  if [ count link-neighbors ] of node-A < (count users - 1) [
    ; find a node distinct from A and not already a neighbor of "A"
    let node-B one-of users with [ (self != node-A) and (not link-neighbor? node-A)]
    ; wire the new edge
    ask node-A [ create-link-with node-B [ set new-link 1 ] ]

    set number-rewired number-rewired + 1
    die ; remove the old edge

  ]
end




;;;;;;;;;;;;;;;;;;;;;
;; Edge Operations ;;
;;;;;;;;;;;;;;;;;;;;;

; creates a new lattice
to wire-users-lattice
  ; iterate over the turtles
  ask users [

    ask min-n-of 2 other users [distance myself]
    [     make-edge self myself
    ]


  ]

end

; Connects two nodes
to make-edge [ node-A node-B ]
  ask node-A [
    create-link-with node-B  [
      set shape "default"
      set new-link 1
      set color gray + 2
    ]
  ]
end




; Copyright 2015 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
10
50
414
455
-1
-1
12.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
0
ticks
30.0

SLIDER
120
10
435
43
num-users
num-users
10
1000
1000.0
1
1
NIL
HORIZONTAL

PLOT
445
235
710
414
User's AW
fraction of edges rewired
NIL
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"apl" 1.0 2 -65485 true "" "plot get-users-AW"

MONITOR
445
120
990
165
NIL
get-links-simis
3
1
11

PLOT
715
235
990
414
RECs total subscriptions
rewiring probability
NIL
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"pen-2" 1.0 2 -4079321 true "" "plot get-PVadopters + get-subscribers"

BUTTON
11
10
116
43
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
535
420
740
486
• - Clustering Coefficient\n
14
55.0
1

TEXTBOX
535
440
755
471
• - Average Path Length
14
15.0
1

SLIDER
440
15
612
48
num-RECs
num-RECs
0
4
0.0
1
1
NIL
HORIZONTAL

MONITOR
65
480
137
525
NIL
count links
17
1
11

BUTTON
450
65
513
98
NIL
go
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
450
180
650
225
NIL
get-users-AW
3
1
11

MONITOR
830
425
1040
470
owner, REC
count users with [made-choice = 1 and housing-condition = 0\n]
17
1
11

MONITOR
830
470
1040
515
owner, PV buy
count users with [made-choice = 2 and housing-condition = 0]
17
1
11

MONITOR
830
515
1040
560
owner, PV loan
count users with [made-choice = 3 and housing-condition = 0 ]
17
1
11

MONITOR
830
555
1042
600
owner, utility el.
count users with [made-choice = 0 and housing-condition = 0 ]
17
1
11

MONITOR
485
515
552
560
NIL
year
17
1
11

MONITOR
625
515
682
560
NIL
month
17
1
11

MONITOR
720
490
792
535
NIL
get-quotas
17
1
11

PLOT
1060
15
1260
165
quotas
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -5516827 true "" "plot get-quotas"

PLOT
1080
240
1280
390
Q of users
NIL
NIL
0.0
2.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "histogram [Q] of users\n"

MONITOR
1085
425
1185
470
non-owner, REC
count users with [made-choice = 1 and housing-condition != 0\n]
17
1
11

MONITOR
1085
470
1207
515
non-owner, PV buy
count users with [made-choice = 2 and housing-condition != 0\n]
17
1
11

MONITOR
1085
515
1207
560
non-owner, PV-loan
count users with [made-choice = 3 and housing-condition != 0\n]
17
1
11

MONITOR
1085
560
1212
605
non-owner, utility el.
count users with [made-choice = 0 and housing-condition != 0\n]
17
1
11

MONITOR
170
485
287
530
NIL
get-visual-influence
17
1
11

MONITOR
170
550
277
595
NIL
get-choices-made
17
1
11

PLOT
1335
465
1535
615
plot 1
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot get-tot-kw\n"

@#$#@#$#@
## WHAT IS IT?

This model explores the formation of networks that result in the "small world" phenomenon -- the idea that a person is only a couple of connections away from any other person in the world.

A popular example of the small world phenomenon is the network formed by actors appearing in the same movie (e.g., "[Six Degrees of Kevin Bacon](https://en.wikipedia.org/wiki/Six_Degrees_of_Kevin_Bacon)"), but small worlds are not limited to people-only networks. Other examples range from power grids to the neural networks of worms. This model illustrates some general, theoretical conditions under which small world networks between people or things might occur.

## HOW IT WORKS

This model is an adaptation of the [Watts-Strogatz model](https://en.wikipedia.org/wiki/Watts-Strogatz_model) proposed by Duncan Watts and Steve Strogatz (1998). It begins with a network where each person (or "node") is connected to his or her two neighbors on either side. Using this a base, we then modify the network by rewiring nodes–changing one end of a connected pair of nodes and keeping the other end the same. Over time, we analyze the effect this rewiring has the on various connections between nodes and on the properties of the network.

Particularly, we're interested in identifying "small worlds." To identify small worlds, the "average path length" (abbreviated "apl") and "clustering coefficient" (abbreviated "cc") of the network are calculated and plotted after a rewiring is performed. Networks with _short_ average path lengths and _high_ clustering coefficients are considered small world networks. See the **Statistics** section of HOW TO USE IT on how these are calculated.

## HOW TO USE IT

The NUM-NODES slider controls the size of the network. Choose a size and press SETUP.

Pressing the REWIRE-ONE button picks one edge at random, rewires it, and then plots the resulting network properties in the "Network Properties Rewire-One" graph. The REWIRE-ONE button _ignores_ the REWIRING-PROBABILITY slider. It will always rewire one exactly one edge in the network that has not yet been rewired _unless_ all edges in the network have already been rewired.

Pressing the REWIRE-ALL button starts with a new lattice (just like pressing SETUP) and then rewires all of the edges edges according to the current REWIRING-PROBABILITY. In other words, it `asks` each `edge` to roll a die that will determine whether or not it is rewired. The resulting network properties are then plotted on the "Network Properties Rewire-All" graph. Changing the REWIRING-PROBABILITY slider changes the fraction of edges rewired during each run. Running REWIRE-ALL at multiple probabilities produces a range of possible networks with varying average path lengths and clustering coefficients.

When you press HIGHLIGHT and then point to a node in the view it color-codes the nodes and edges. The node itself turns white. Its neighbors and the edges connecting the node to those neighbors turn orange. Edges connecting the neighbors of the node to each other turn yellow. The amount of yellow between neighbors gives you a sort of indication of the clustering coefficient for that node. The NODE-PROPERTIES monitor displays the average path length and clustering coefficient of the highlighted node only. The AVERAGE-PATH-LENGTH and CLUSTERING-COEFFICIENT monitors display the values for the entire network.

### Statistics

**Average Path Length**: Average path length is calculated by finding the shortest path between all pairs of nodes, adding them up, and then dividing by the total number of pairs. This shows us, on average, the number of steps it takes to get from one node in the network to another.

In order to find the shortest paths between all pairs of nodes we use the [standard dynamic programming algorithm by Floyd Warshall] (https://en.wikipedia.org/wiki/Floyd-Warshall_algorithm). You may have noticed that the model runs slowly for large number of nodes. That is because the time it takes for the Floyd Warshall algorithm (or other "all-pairs-shortest-path" algorithm) to run grows polynomially with the number of nodes.

**Clustering Coefficient**: The clustering coefficient of a _node_ is the ratio of existing edges connecting a node's neighbors to each other to the maximum possible number of such edges. It is, in essence, a measure of the "all-my-friends-know-each-other" property. The clustering coefficient for the entire network is the average of the clustering coefficients of all the nodes.

### Plots

1. The "Network Properties Rewire-One" visualizes the average-path-length and clustering-coefficient of the network as the user increases the number of single-rewires in the network.

2. The "Network Properties Rewire-All" visualizes the average-path-length and clustering coefficient of the network as the user manipulates the REWIRING-PROBABILITY slider.

These two plots are separated because the x-axis is slightly different.  The REWIRE-ONE x-axis is the fraction of edges rewired so far, whereas the REWIRE-ALL x-axis is the probability of rewiring.

The plots for both the clustering coefficient and average path length are normalized by dividing by the values of the initial lattice. The monitors CLUSTERING-COEFFICIENT and AVERAGE-PATH-LENGTH give the actual values.

## THINGS TO NOTICE

Note that for certain ranges of the fraction of nodes rewired, the average path length decreases faster than the clustering coefficient. In fact, there is a range of values for which the average path length is much smaller than clustering coefficient. (Note that the values for average path length and clustering coefficient have been normalized, so that they are more directly comparable.) Networks in that range are considered small worlds.

## THINGS TO TRY

Can you get a small world by repeatedly pressing REWIRE-ONE?

Try plotting the values for different rewiring probabilities and observe the trends of the values for average path length and clustering coefficient.  What is the relationship between rewiring probability and fraction of nodes? In other words, what is the relationship between the rewire-one plot and the rewire-all plot?

Do the trends depend on the number of nodes in the network?

Set NUM-NODES to 80 and then press SETUP. Go to BehaviorSpace and run the VARY-REWIRING-PROBABILITY experiment. Try running the experiment multiple times without clearing the plot (i.e., do not run SETUP again).  What range of rewiring probabilities result in small world networks?

## EXTENDING THE MODEL

Try to see if you can produce the same results if you start with a different type of initial network. Create new BehaviorSpace experiments to compare results.

In a precursor to this model, Watts and Strogatz created an "alpha" model where the rewiring was not based on a global rewiring probability. Instead, the probability that a node got connected to another node depended on how many mutual connections the two nodes had. The extent to which mutual connections mattered was determined by the parameter "alpha." Create the "alpha" model and see if it also can result in small world formation.

## NETLOGO FEATURES

Links are used extensively in this model to model the edges of the network. The model also uses custom link shapes for neighbor's neighbor links.

Lists are used heavily in the procedures that calculates shortest paths.

## RELATED MODELS

See other models in the Networks section of the Models Library, such as Giant Component and Preferential Attachment.

Check out the NW Extension General Examples model to see how similar models might implemented using the built-in NW extension.

## CREDITS AND REFERENCES

This model is adapted from: Duncan J. Watts, Six Degrees: The Science of a Connected Age (W.W. Norton & Company, New York, 2003), pages 83-100.

The work described here was originally published in: DJ Watts and SH Strogatz. Collective dynamics of 'small-world' networks, Nature, 393:440-442 (1998).

The small worlds idea was first made popular by Stanley Milgram's famous experiment (1967) which found that two random US citizens where on average connected by six acquaintances (giving rise to the popular "six degrees of separation" expression): Stanley Milgram. The Small World Problem, Psychology Today, 2: 60-67 (1967).

This experiment was popularized into a game called "six degrees of Kevin Bacon" which you can find more information about here: https://oracleofbacon.org

Thanks to Connor Bain for updating this model in 2020.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. (2015).  NetLogo Small Worlds model.  http://ccl.northwestern.edu/netlogo/models/SmallWorlds.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2015 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

<!-- 2015 -->
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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
setup
repeat 5 [rewire-one]
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="vary-rewiring-probability" repetitions="5" runMetricsEveryStep="false">
    <go>rewire-all</go>
    <timeLimit steps="1"/>
    <exitCondition>rewiring-probability &gt; 1</exitCondition>
    <metric>average-path-length</metric>
    <metric>clustering-coefficient</metric>
    <steppedValueSet variable="rewiring-probability" first="0" step="0.025" last="1"/>
  </experiment>
</experiments>
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

curve
3.0
-0.2 0 0.0 1.0
0.0 0 0.0 1.0
0.2 1 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

curve-a
-3.0
-0.2 0 0.0 1.0
0.0 0 0.0 1.0
0.2 1 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
