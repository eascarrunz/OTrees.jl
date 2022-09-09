# struct definitions, constructor methods, and show methods of core types

mutable struct Branch{D}
    length::Union{Nothing,Float64}
    label::String
    data::D

    Branch{D}(length=nothing, label="") where {D} = new{D}(length, label)
end


mutable struct NodeView{T} <: AbstractNode
    id::PhylInt
    node::Union{Nothing,T}
    out::Union{Nothing,NodeView}
    next::Union{Nothing,NodeView}
    branch::Branch

    NodeView{T}(id, node=nothing) where {T} = new{T}(id, node, nothing, nothing)
end

function Base.show(io::IO, nv::NodeView)
    nodeinfo = isnothing(nv.node) ? "not assigned to a node" : "assigned to node #$(nv.node.id)"
    print(io, "NodeView #$(nv.id) $(nodeinfo)")

    return nothing
end


mutable struct ONode{D} <: AbstractNode
    id::PhylInt
    taxon::Union{Nothing,Taxon}
    label::String
    lastview::Union{Nothing,NodeView}
    data::D

    ONode(D, id, taxon::Union{Nothing,Taxon} = nothing) =
        new{D}(id, taxon, isnothing(taxon) ? "" : taxon.name, nothing)
    ONode(D, id, label::String) =
        new{D}(id, nothing, label, nothing)
end


Base.show(io::IO, p::ONode) = print(io, "ONode #$(p.id)")


NodeView(id, node=nothing) = NodeView{ONode}(id, node)


mutable struct OTree{D}
    anchor::ONode
    nodes::Vector{ONode}
    nodeviews::Vector{NodeView}
    data::D

    OTree{D}(anchor, nodes, nodeviews) where {D} = new{D}(anchor, nodes, nodeviews)
end


Base.show(io::IO, tree::OTree) = print(io, "OTree with $(length(tree.nodes)) nodes")


function Base.propertynames(::NodeView, private=false)
    return private ? (
        :branch,
        :brlength,
        :data,
        :id,
        :label,
        :next,
        :node,
        :viewid,
        :taxon,
        :out
    ) : (
        :branch,
        :brlength,
        :data,
        :id,
        :label,
        :next,
        :node,
        :viewid,
        :taxon,
    )
end


function Base.setproperty!(nodeview::NodeView, property::Symbol, value)
    # `out` and `next` have public getters, but are not intended to have a public setter

    property == :branch     && return setfield!(nodeview, :branch, value)
    property == :brlength   && return setfield!(nodeview.branch, :length, value)
    property == :data       && return setfield!(nodeview.node, :data, value)
    property == :id         && return setfield!(nodeview.node, :id, value)
    property == :label      && return setfield!(nodeview.node, :label, value)
    property == :node       && return setfield!(nodeview, :node, value)
    property == :viewid     && return setfield!(nodeview, :id, value)
    property == :out        && return setfield!(nodeview, :out, value)
    property == :taxon      && return setfield!(nodeview.node, :taxon, value)

    throw(error("type `NodeView` has no public property `$(property)`"))
end


function Base.getproperty(nodeview::NodeView, property::Symbol)
    property == :branch     && return getfield(nodeview, :branch)
    property == :brlength   && return getfield(nodeview.branch, :length)
    property == :data       && return getfield(nodeview.node, :data)
    property == :id         && return getfield(nodeview.node, :id)
    property == :label      && return getfield(nodeview.node, :label)
    property == :next       && return getfield(nodeview, :next)
    property == :node       && return getfield(nodeview, :node)
    property == :out        && return getfield(nodeview, :out)
    property == :taxon      && return getfield(nodeview.node, :taxon)
    property == :viewid     && return getfield(nodeview, :id)

    throw(error("type `NodeView` has no public property `$(property)`"))
end
