'**********Copyright 2016 Roku Corp.  All Rights Reserved. : ANDY YU **********
sub init()
    ' Initialize variables for component fields
    m.flip_duration = "1.5"     ' time to make a 45 degree turn, placeholder / default: 1.5
    m.width = 0                 ' width of each side
    m.height = 0                ' height of each side
    m.side = 0                  ' counter to decide which sides are being flipped
    
    ' Start flipTimer
    m.flipTimer = m.top.findNode("flipTimer")
    m.flipTimer.control = "start"
    m.flipTimer.ObserveField("fire", "flipWrapper")
    
    ' Local (component level) references to nodes
    m.topSide = m.top.findNode("Top")
    m.leftSide = m.top.findNode("Left")
    m.rightSide = m.top.findNode("Right")
    m.bottomSide = m.top.findNode("Bottom")
    m.midEdge = m.top.findNode("MidEdge")
    m.leftEdge = m.top.findNode("LeftEdge")
    m.rightEdge = m.top.findNode("RightEdge")
end sub

' Callback functions for interface field changes
sub setRotateDuration()
    temp = (m.top.rotate_duration.toInt()/4).toStr() ' divide the time for a full rotation by 4 to get a single side's duration
    m.flipTimer.duration = temp
    m.flip_duration = temp
end sub

sub setWidth()
    m.width = m.top.width.toInt()  ' cast a roString -> roInteger
    m.topSide.width = m.top.width   ' only display top side first, every other side will be generated by animations
end sub

sub setHeight()
    m.height = m.top.height.toInt().getInt()    ' cast a roString -> roInteger
    m.topSide.height = m.top.height
    m.leftSide.height = m.top.height
    m.rightSide.height = m.top.height
    m.bottomSide.height = m.top.height
    m.midEdge.height = m.top.height
    m.leftEdge.height = m.top.height
    m.rightEdge.height = m.top.height
end sub
'//////////////////'

' Never used. Potentially useful?
sub clearCubes()
    m.topSide.visible = false
    m.leftSide.visible = false
    m.rightSide.visible = false
    m.bottomSide.visible = false
    m.edge.visible = false
end sub

' flipSide() wrapper that accepts no parameters to be used as a callback for flipTimer
sub flipWrapper()
    if m.side = 0
        flipSide("Top", "Left", m.flip_duration)
        m.side += 1
    else if m.side = 1
        flipSide("Left", "Right", m.flip_duration)
        m.side += 1
    else if m.side = 2
        flipSide("Right", "Bottom", m.flip_duration)
        m.side += 1
    else if m.side = 3
        flipSide("Bottom", "Top", m.flip_duration)
        m.side = 0
    endif
end sub

' "Flip" from one side (orig) of the cube to another (dest) in (time) seconds
function flipSide(orig as String, dest as String, time as String) as Boolean
    ' m.top.rotation += 0.1
    ' First clean up previous animation nodes
    m.top.removeChild(m.midEdge_anim)
    m.top.removeChild(m.midEdge_anim2)
    m.top.removeChild(m.leftEdge_anim)
    m.top.removeChild(m.leftEdge_anim2)
    m.top.removeChild(m.rightEdge_anim)
    m.top.removeChild(m.rightEdge_anim2)
    
    m.top.removeChild(m.orig_scale_anim)
    m.top.removeChild(m.orig_loc_anim)
    m.top.removeChild(m.dest_scale_anim)
    m.top.removeChild(m.dest_loc_anim)

    ' Initialize sides
    origin      = Invalid
    destination = Invalid
    width = m.width.GetInt()    ' function scope references to side width and height
    height = m.height.GetInt()  ' cast roInteger -> Int
    diag_growth = width*0.125
    
        ' identify which sides are being flipped (origin / destination)
    side_list = {"Top" : m.topSide, "Left": m.leftSide, "Right": m.rightSide, "Bottom": m.bottomSide}
    for each side in side_list
        if LCase(orig) = side
            origin = side_list[side]
            origin.visible = true
        else if LCase(dest) = side
            destination = side_list[side]
            destination.visible = true
        endif
    endfor
    
    if (origin = Invalid) or (destination = Invalid)
        return False
    endif
    '//////////////////'
    
    ' Clean up any leftover sides (problem occurs if loop starts before animation is able to complete)
    side_list = [m.topSide, m.leftSide, m.rightSide, m.bottomSide]
    for each side in side_list
        if origin.id <> side.id and destination.id <> side.id   ' if they are hidden sides 
            side.width = 1                                      ' poster minimum width is 1 and visibility is false
            side.visible = False                                ' this should be the case except for
        endif                                                   ' if the previous animation loop was interrupted
    endfor
    
    
    ' The entirety of the animation is done with
    '   - 3 edge translation animations (1 for each edge)
    '   - 3 edge scale animations
    '   - 2 side translation animations (1 for origin, 1 for destination)
    '   - 2 side scale animations (1 for origin, 1 for destination)
    
    ' Middle Edge '
    midEdge = m.midEdge
    m.midEdge.translation = [width, midEdge.translation[1]]
    m.midEdge.width = 3
    
    ' Translate edge
    m.midEdge_anim=CreateObject("roSGNode", "Animation")
    m.midEdge_anim.id="midEdge_anim"
    m.midEdge_anim.duration=time
    m.midEdge_anim.easeFunction="linear"
    m.midEdge_interp=CreateObject("roSGNode", "Vector2DFieldInterpolator")
    m.midEdge_interp.id="midEdge_interp"
    m.midEdge_interp.key=[0.0, 1.0]
    m.midEdge_interp.keyValue=[[width, 0], [0, 0]]
    m.midEdge_interp.fieldToInterp="MidEdge.translation"
    m.midEdge_anim.appendChild(m.midEdge_interp)
    m.top.appendchild(m.midEdge_anim)
    
    ' Disappear edge
    m.midEdge_anim2=CreateObject("roSGNode", "Animation")
    m.midEdge_anim2.id="midEdge_anim2"
    m.midEdge_anim2.duration=time
    m.midEdge_anim2.easeFunction="Linear"
    m.midEdge_interp2=CreateObject("roSGNode", "FloatFieldInterpolator")
    m.midEdge_interp2.id="midEdge_interp2"
    m.midEdge_interp2.key=[0.0, 0.95, 1.0]
    m.midEdge_interp2.keyValue=[3, 3, 0]
    m.midEdge_interp2.fieldToInterp="MidEdge.width"
    m.midEdge_anim2.appendChild(m.midEdge_interp2)
    m.top.appendchild(m.midEdge_anim2)
    '//////////////////'
    
    ' Left Edge '
    leftEdge = m.leftEdge
    leftEdge.translation = [0, leftEdge.translation[1]]
    leftEdge.width = 3
    
    ' Translate edge
    m.leftEdge_anim=CreateObject("roSGNode", "Animation")
    m.leftEdge_anim.id="leftEdge_anim"
    m.leftEdge_anim.duration=time
    m.leftEdge_anim.easeFunction="linear"
    m.leftEdge_interp=CreateObject("roSGNode", "Vector2DFieldInterpolator")
    m.leftEdge_interp.id="leftEdge_interp"
    m.leftEdge_interp.key=[0.0, 0.5, 1.0]
    m.leftEdge_interp.keyValue=[[0, 0], [-1*diag_growth, 0], [0, 0]]
    m.leftEdge_interp.fieldToInterp="LeftEdge.translation"
    m.leftEdge_anim.appendChild(m.leftEdge_interp)
    m.top.appendchild(m.leftEdge_anim)
    
    ' Disappear edge
    m.leftEdge_anim2=CreateObject("roSGNode", "Animation")
    m.leftEdge.id="leftEdge_anim2"
    m.leftEdge_anim2.duration=time
    m.leftEdge_anim2.easeFunction="Linear"
    m.leftEdge_interp2=CreateObject("roSGNode", "FloatFieldInterpolator")
    m.leftEdge_interp2.id="leftEdge_interp2"
    m.leftEdge_interp2.key=[0.0, 1.0]
    m.leftEdge_interp2.keyValue=[3, 0]
    m.leftEdge_interp2.fieldToInterp="LeftEdge.width"
    m.leftEdge_anim2.appendChild(m.leftEdge_interp2)
    m.top.appendchild(m.leftEdge_anim2)
    '//////////////////'
    
    ' Right Edge '
    rightEdge = m.rightEdge
    rightEdge.translation = [m.width, 0]
    rightEdge.width = 0
    
    ' Translate edge
    m.rightEdge_anim=CreateObject("roSGNode", "Animation")
    m.rightEdge.id="rightEdge_anim"
    m.rightEdge_anim.duration=time
    m.rightEdge_anim.easeFunction="linear"
    m.rightEdge_interp=CreateObject("roSGNode", "Vector2DFieldInterpolator")
    m.rightEdge_interp.id="rightEdge_interp"
    m.rightEdge_interp.key=[0.0, 0.5, 1.0]
    m.rightEdge_interp.keyValue=[[width + 3, 0], [width+diag_growth, 0], [width, 0]]
    m.rightEdge_interp.fieldToInterp="RightEdge.translation"
    m.rightEdge_anim.appendChild(m.rightEdge_interp)
    m.top.appendchild(m.rightEdge_anim)
    
    ' Disappear edge
    m.rightEdge_anim2=CreateObject("roSGNode", "Animation")
    m.rightEdge.id="rightEdge_anim2"
    m.rightEdge_anim2.duration=time
    m.rightEdge_anim2.easeFunction="Linear"
    m.rightEdge_interp2=CreateObject("roSGNode", "FloatFieldInterpolator")
    m.rightEdge_interp2.id="rightEdge_interp2"
    m.rightEdge_interp2.key=[0.0, 0.5, 1]
    m.rightEdge_interp2.keyValue=[0, 2.5, 3]
    m.rightEdge_interp2.fieldToInterp="RightEdge.width"
    m.rightEdge_anim2.appendChild(m.rightEdge_interp2)
    m.top.appendchild(m.rightEdge_anim2)
    '//////////////////'
    
    ' Origin '
    ' Interpolate scale
    m.orig_scale_anim=CreateObject("roSGNode", "Animation")
    m.orig_scale_anim.id="os_anim"
    m.orig_scale_anim.duration=time
    m.orig_scale_anim.easeFunction="linear"
    m.orig_scale_interp=CreateObject("roSGNode", "FloatFieldInterpolator")
    m.orig_scale_interp.id="os_interp"
    m.orig_scale_interp.fieldToInterp=orig+".width"
    m.orig_scale_interp.key=[0.0, 0.5, 1.0]
    m.orig_scale_interp.keyValue=[width, width/2+diag_growth, 0]
    m.orig_scale_anim.appendChild(m.orig_scale_interp)
    m.top.appendchild(m.orig_scale_anim)
    
    ' Interpolate location
    m.orig_loc_anim=CreateObject("roSGNode", "Animation")
    m.orig_loc_anim.id="ol_anim"
    m.orig_loc_anim.duration=time
    m.orig_loc_anim.easeFunction="linear"
    m.orig_loc_interp=CreateObject("roSGNode", "Vector2DFieldInterpolator")
    m.orig_loc_interp.id="ol_interp"
    m.orig_loc_interp.key=[0.0, 0.5, 1.0]
    m.orig_loc_interp.keyValue=[[0, 0], [-1*diag_growth, 0], [0, 0]]
    m.orig_loc_interp.fieldToInterp=orig+".translation"
    m.orig_loc_anim.appendChild(m.orig_loc_interp)
    m.top.appendchild(m.orig_loc_anim)
    '//////////////////'
    
    ' Destination '
    ' Pre-animation setup
    destination.translation = [destination.translation[0]+m.width, 0]
    
    ' Interpolate scale
    m.dest_scale_anim=CreateObject("roSGNode", "Animation")
    m.dest_scale_anim.id="ds_anim"
    m.dest_scale_anim.duration=time
    m.dest_scale_anim.easeFunction="linear"
    m.dest_scale_interp=CreateObject("roSGNode", "FloatFieldInterpolator")
    m.dest_scale_interp.id="ds_interp"
    m.dest_scale_interp.fieldToInterp=dest+".width"
    m.dest_scale_interp.key=[0.0, 0.5, 1.0]
    m.dest_scale_interp.keyValue=[1, width/2+diag_growth, width]    ' start width must be 1 since poster min width is 1
    m.dest_scale_anim.appendChild(m.dest_scale_interp)
    m.top.appendchild(m.dest_scale_anim)
    
    ' Interpolate location
    m.dest_loc_anim=CreateObject("roSGNode", "Animation")
    m.dest_loc_anim.id="dl_anim"
    m.dest_loc_anim.duration=time
    m.dest_loc_anim.easeFunction="linear"
    m.dest_loc_interp=CreateObject("roSGNode", "Vector2DFieldInterpolator")
    m.dest_loc_interp.id="dl_interp"
    m.dest_loc_interp.key=[0.0, 1.0]
    m.dest_loc_interp.keyValue=[[width, 0], [0, 0]]
    m.dest_loc_interp.fieldToInterp=dest+".translation"
    m.dest_loc_anim.appendChild(m.dest_loc_interp)
    m.top.appendchild(m.dest_loc_anim)
    '//////////////////'
    
    ' Begin animations '
    ' edges
    m.midEdge_anim.control      = "start"
    m.midEdge_anim2.control     = "start"
    m.leftEdge_anim.control     = "start"
    m.leftEdge_anim2.control    = "start"
    m.rightEdge_anim.control    = "start"
    m.rightEdge_anim2.control   = "start"
    ' sides
    m.orig_scale_anim.control   = "start"
    m.orig_loc_anim.control     = "start"
    m.dest_scale_anim.control   = "start"
    m.dest_loc_anim.control     = "start"
    '//////////////////'
    
   ' if dest = "Left"
   '    stop
   'endif
    return True
end function

' Not working onKeyEvent
function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if press then
        if key = "up" then
            ?"Cube registered keypress!"
            topSide.visible = true
            flipSide("Top", "", "5")
            handled = true
        else if key = "left" then
            leftSide.visible = true
            flipSide("Left", "", "5")
            handled = true
        else if key = "right" then
            rightSide.visible = true
            flipSide("Right", "", "5")
            handled = true
        else if key = "down" then
            downSide.visible = true
            flipSide("Down", "", "5")
            handled = true
        else
            handle = false
        end if
    end if
end function

