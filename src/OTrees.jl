module OTrees

abstract type AbstractTree end
abstract type AbstractRTree <: AbstractTree end
abstract type AbstractUTree <:AbstractTree end

abstract type AbstractNode end
abstract type AbstractRNode <: AbstractNode end
abstract type AbstractUNode <: AbstractNode end

const PhylInt = UInt16    # Alias for the integer type to use for object IDs

const DEFAULT_DTYPES = (Dict{Symbol,Any}, Dict{Symbol,Any}, Dict{Symbol,Any})

include("taxa.jl")
export TaxonSet, setname!, add!

include("numbers.jl")
export nnode, nview

include("core_types.jl")
export OTree

include("branches.jl")
export brlength, brlength!, brlabel, brlabel!

include("relatives.jl")
export neighbours, children, getview

include("linking.jl")
export link!, linkfirst!, unlink!, swap!

include("construct_trees.jl")
export create_tree, symmetric_tree

include("write_newick.jl")
include("read_newick.jl")

end
