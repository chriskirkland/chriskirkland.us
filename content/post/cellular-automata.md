+++
date = "2016-09-26T11:09:19-05:00"
description = "Demonstrating 1-dimensional Cellular Automata using JavaScript/HTML/CSS"
tags = []
title = "Cellular Automata"
topics = ["Cellular Automata", "JavaScript", "HTML", "CSS", "Side Projects"]

+++
### Inspiration

It has been several years since I've touched any front-end web technologies.
Past projects included:

* Rebuilding the Mercer University Computer Science deparment [website](http://www.cs.mercer.edu/faculty/).
* Building a [personal website](http://www4.ncsu.edu/~cmkirkla/) for hosting syllabi, course materials, etc. while teaching in Grad school.
* This blog; built using [Hugo](https://gohugo.io/) which is <i>technically</i> cheating.

So recently I've been looking for an excuse to brush up on JavaScript, in particular.  The inspiration for this side project came from
this [video](https://www.youtube.com/watch?v=bc-fVdbjAwk) from MPJ's popular series "Fun Fun Function"; if you haven't seen any of his videos already,
<i>shame on you</i>.  As an additional constraint, I decided to use pure JavaScript for this project---foregoing any frameworks (`Node`, `Angular`, etc.) or
libraries (looking at you `jQuery`) which I've used in the past as a crutch.

I'll explain some of the features of the finished project below, but, if you prefer, jump straight into the [demo hosted on GitHub Pages](https://chriskirkland.github.io/cellular-automata/)!

### Cellular Automata

If you have seen [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) then you are already
familiar with the principles behind Cellular Automata; the Game of Life is an example of a 2D Cellular Automaton.
In general, a Cellular Automaton is a computational model consisting of a regular grid of cells, with each cell occupying one of a finite number of state (usually just "active" and "inactive"),
and a rule which governs how generations <i>evolve</i>.  Most common rules for Cellular Automata assign a future state to a cell based on the current state of the cell and the states of it's <i>neighbors</i>
(i.e. surrounding cells).  For example, here is the 1D Cellular Automata [rule 30](http://mathworld.wolfram.com/Rule30.html):

<center>
  <img src="/cellular-automata/CA-rule-30.gif" alt"CA rule 30" />
</center>

Here the first "sub-rule" above states that if the current cell and both of its neighbors is active in current generation, the current cell will be inactive in the next generation.

In the case of 1D Cellular Automata, there are 3 states to consider in each rule (self + 2 neighbors).  In the case of 2D automaton, there are 9 states to consider (self + 8 neighbors).  For 3D, there are 27. And so on.
It is worth noting that this assumes (1) we're using Euclidean distance as our metic and (2) we consider neighbors to be cells with distance 1 from the current cell; other notions of distance will give rise to very different rulesets and Automata.
<b>For this project, I've limited myself to 1D Cellular Automata</b>.

Additionally, <b>I've added a "random" state to the possible CA states</b>.  For the main grid area, a random cell has it's state chosen when it's generation is populated and stays fixed thereafter.
However, inside of the rule visualization bar, cells with random states are represented by "?".

### Features

* Select the desired colors for the "active" and "inactive" states
* Visualize a given Cellular Automata rule by clicking "visualize"
* Change the CA rule on-the-fly by toggling the child cells in the visualization bar between "active", "inactive", and "random" (i.e. "?")
* Automatically resize the main display area when the browser is resized

Additionally there is a link to the [source code](https://github.com/chriskirkland/cellular-automata) in the top left of the webpage as well
as a link to some [educational materials](https://github.com/chriskirkland/cellular-automata/wiki) in the footer.

<img src="/cellular-automata/cellular-automata-features.gif" alt="Cellular Automata demonstration" />

Demo Gif created using [LICEcap](http://www.cockos.com/licecap/) for OSX.

