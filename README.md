# Haxe layout lib

This library is mostly a proof of concept even though the layout system has been used in production in some mini games.

## Philosophy

The library has been designed to allow eveloper to create UI directly from a layout XML files. The layout if engine independant and works through a callback system when layout changes to allows UI to adapt to new contraints.

## Features 

 * CanvasLayout:  a layout with no specific contraints between elements themselves. To be compared with css absolute positionning.
 * BoxLayout : box horizontal and vertical layout. Some child padding, aspect ratio of elements, autosizing ..
 * ElementStack : to switch elements based on interaction. See it like tabs.
 * Metrics : macro and abstract pixel representation to support different units for width/height/padding... Supported Units : %, dp, pixes, cm, vpx, pt ...

## Stability
The layout part only was tested and is expected to work properly.  Resolution of constraints, units, padding and different supported layouts should be pretty robust.

Hot reloading support might not be fully working in all scenarios.

Heaps support, Styling and events and some proof of concept only for now.


## Platforms
For now, only heaps engine has some support, and Samples are based on that engin.
But once again, the philosophy is to make it agnostic, so very very little changes are expected.  (e.g  Metrics.hx class use heaps to get windows width/heigh only).

