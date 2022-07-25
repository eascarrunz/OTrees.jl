#=
If a linking function is called when `p.next` is `nothing`, a `TypeError` exception will be thrown by `_addstem!`
=#

function _addstem!(stem1::NodeView, stem2::NodeView)
    stem2.next = stem1.next
    stem1.next = stem2
  
    stem2.node = stem1.node
  
    return nothing
end


"""
  linkfirst!(p, c)

Link node `p` to node `c`. `c` is made the first child of `p`.

When child order does not matter, prefer `linkfirst!` over `link!` for speed.
"""
linkfirst!(p, c) = _addstem!(p, c.out)


"""
  link!(p, c)

Link node `p` to node `c`.
"""
link!(p, c) = _addstem!(lastview(p), c.out)

link!(p::ONode, c::ONode) = _addstem!(p, lastview(c).out)

function _addstem!(p::ONode, stemc::NodeView)
  if isnothing(p.lastview)
    stemc.next = stemc
  else
    stemc.next = p.lastview.next
    p.lastview.next = stemc
  end
  p.lastview = stemc
  stemc.node = p
end


function _addstem!(stemp::NodeView, c::ONode)
  if isnothing(c.lastview)
    c.lastview = stemp
    stemp.next = stemp
    stemp.node = c
  else
    _addstem!(stemp, c.lastview)
  end

  return nothing
end


"""
  unlink!(c)

Separate node `c` from its parent. The branch remains attached to `c`.
"""
function unlink!(c::NodeView)
  stemc = c.out
  prevsib = lastview(stemc)
  nextsib = stemc.next

  prevsib.next = nextsib
  stemc.node = nothing

  return nothing
end


"""
  swap!(c1::NodeView, c2::NodeView)

Exchange the parents of nodes `c1` and `c2`.

`swap!` is faster than manually unlinking and relinking the nodes.
"""
function swap!(c1::NodeView, c2::NodeView)
  stemc1 = c1.out
  prevc1 = lastview(stemc1)
  nextc1 = stemc1.next

  stemc2 = c2.out
  prevc2 = lastview(stemc2)
  nextc2 = stemc2.next

  prevc2.next = stemc1
  stemc1.next = nextc2
  stemc1.node = stemc1.next.node

  prevc1.next = stemc2
  stemc2.next = nextc1
  stemc2.node = stemc2.next.node

  return nothing
end
