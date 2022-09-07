# ---------------------------------------------------------------------------- #
#                              Iterator interface                              #
# ---------------------------------------------------------------------------- #

struct NodeViewIterator{T}
    first::T
    stopbefore::T

    NodeViewIterator(first::T, stopbefore::T) where T = new{T}(first, stopbefore)
end
  
Base.iterate(::NodeViewIterator{Nothing}) = nothing
Base.iterate(iter::NodeViewIterator{NodeView{ONode}}) = (iter.first.out, getfield(iter.first, :next))
Base.iterate(iter::NodeViewIterator{NodeView{ONode}}, state) =
    state ≢ iter.stopbefore ? (state.out, getfield(state, :next)) : nothing

Base.IteratorSize(::NodeViewIterator) = Base.HasLength()
Base.IteratorEltype(::NodeViewIterator) = Base.HasEltype()
Base.eltype(::NodeViewIterator) = NodeView
Base.length(iter::NodeViewIterator{NodeView{ONode}}) = sum(1 for _ in iter)
Base.length(::NodeViewIterator{Nothing}) = 0
Base.last(::NodeViewIterator{Nothing}) = nothing
function Base.last(iter::NodeViewIterator{NodeView{ONode}})
    x = first(iter)
    for y in iter
        x = y
    end

    return x
end


# The NodeIterator interface simply wraps the type and logic of the NodeViewIterator interface
struct NodeIterator{T}
    viewiter::T

    NodeIterator(iter::T) where T = new{T}(iter)
end

Base.iterate(::NodeIterator{Nothing}) = nothing
function Base.iterate(iter::NodeIterator{NodeViewIterator{NodeView{ONode}}})
    result = iterate(iter.viewiter)

    return isnothing(result) ? nothing : (result[1].node, result[2])
end
function Base.iterate(iter::NodeIterator{NodeViewIterator{NodeView{ONode}}}, state)
    result = iterate(iter.viewiter, state)

    return isnothing(result) ? nothing : (result[1].node, result[2])
end

Base.IteratorSize(::NodeIterator) = Base.HasLength()
Base.IteratorEltype(::NodeIterator) = Base.HasEltype()
Base.eltype(::NodeIterator) = ONode
Base.length(iter::NodeIterator{NodeViewIterator{NodeView{ONode}}}) = sum(! isnothing(o) for o in iter)
Base.length(iter::NodeIterator{Nothing}) = 0
Base.last(iter::NodeIterator) = last(iter.viewiter).node


# ---------------------------------------------------------------------------- #
#                                User functions                                #
# ---------------------------------------------------------------------------- #

"""
Return the stem of the last child of node view `p`.
"""
function lastview(p::NodeView)
#   s = p.next
    s = getfield(p, :next)
  isnothing(s) && return nothing
#   while s.next ≠ p
  while getfield(s, :next) ≠ p
    s = getfield(s, :next)
  end

  return s
end


lastview(o::ONode) = isnothing(o.lastview) ? nothing : o.lastview
firstview(o::ONode) = isnothing(lastview(o)) ? nothing : getfield(lastview(o), :next)


"""
    neighbours(o::ONode)
    neighbours(v::NodeView)

Return an interator of the neighbour nodes of node `o`, or the neighbour node views of node view `v`.
"""
neighbours(s::NodeView) = NodeViewIterator(s, s)
neighbours(o::ONode) = NodeIterator(
    isnothing(lastview(o)) ? nothing : neighbours(firstview(o))
    )


"""
    children(v)

Return an iterator of the children node views of node view `v`.
"""
children(p::NodeView) =
    # p.next ≢ p ? NodeViewIterator(p.next, p) : NodeViewIterator(nothing, nothing)
    getfield(p, :next) ≢ p ? NodeViewIterator(getfield(p, :next), p) : NodeViewIterator(nothing, nothing)


"""
Get the node view from node `op` to node `oc`. Throws an error if the node view does not exist.
"""
function getview(op, oc)
    for v in neighbours(getfield(op.lastview, :next))
        v.out.node ≡ oc && return v
    end

    throw(ErrorException("there is no view from node `op` to node `oc`"))
end

