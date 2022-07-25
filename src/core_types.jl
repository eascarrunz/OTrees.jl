# struct definitions, constructor methods, and show methods of core types

mutable struct Branch{D}
    length::Float64
    label::String
    data::D

    Branch{D}(length=NaN, label="") where {D} = new{D}(length, label)
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
