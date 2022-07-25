#TODO: Adapt this code from `RootedTrees`

brlstring(brl::Number) = ':' * string(brl)
brlstring(::Nothing) = ""    # Branch lengths currently cannot be `nothing` (but maybe they should be)

"""
This function exists so that the same code in `create_newick` returns a string or prints to an IO (which is much faster), depending on the first argument
"""
_nwkout(o::String, s...) = string(o, s...)
function _nwkout(nwk::IO, s)
    print(nwk, s...)

    return nwk
end

function create_newick(nwk, vp::NodeView; brlengths=true)
    nc = length(children(vp))
    if nc > 0
        nwk = _nwkout(nwk, '(')
        for (i, c) in enumerate(children(vp))
            nwk = create_newick(nwk, c; brlengths=brlengths)
            nwk = i < nc ? _nwkout(nwk, ',') : nwk
        end
        nwk = _nwkout(nwk, ')')
    end
    nwk = _nwkout(nwk, vp.node.label)
    nwk = brlengths ? _nwkout(nwk, brlstring(brlength(vp))) : nwk

    return nwk
end

"""
    newick(node; brlengths=true, fmt=nothing)

Return a Newick string representation of the clade under a `node`. Will not include branch lengths if `brlengths` is set to `false`.
"""
newick(vp::NodeView; brlengths=true) = create_newick("", vp; brlengths=brlengths) * ";"

newick(tree::OTree; brlengths=true) = newick(OTrees.firstview(tree.anchor); brlengths=brlengths)

"""
"""
function print_newick(io::IO, tree::OTree; brlengths=true)
    create_newick(io, firstview(tree.anchor), brlengths=brlengths)
    print(io, ';')

    return nothing
end
