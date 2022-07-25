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

function create_newick_fork(nwk, vp, viewlist; brlengths = true)
    nc = length(viewlist)
    if nc > 0
        nwk = _nwkout(nwk, '(')
        for (i, c) in enumerate(viewlist)
            nwk = create_newick_fork(nwk, c, children(c); brlengths=brlengths)
            nwk = i < nc ? _nwkout(nwk, ',') : nwk
        end
        nwk = _nwkout(nwk, ')')
    end
    nwk = _nwkout(nwk, vp.node.label)
    nwk = brlengths ? _nwkout(nwk, brlstring(brlength(vp))) : nwk    
end


_newick(vp::NodeView; brlengths=true) = create_newick_fork("", vp, children(vp); brlengths=brlengths)


"""
newick(tree; brlengths=true)
newick(node; brlengths=true)
newick(nodeview; brlengths=true)

Return a Newick string representation of a tree.

If a `node` is given, it will be used as the root of the Newick string. Give a `nodeview` instead of a node in order to get the Newick string of a subtree.
Will not include branch lengths if `brlengths` is set to `false`.
"""
newick(vp::NodeView; brlengths = true) = _newick(vp; brlengths=brlengths) * ';'
function newick(o::ONode; brlengths = true)
    vp  = firstview(o)
    nwk = create_newick_fork("", vp, neighbours(vp); brlengths=brlengths)

    return nwk * ';'
end
newick(tree::OTree; brlengths = true) = newick(tree.anchor; brlengths = brlengths)

"""
"""
function print_newick(io::IO, tree::OTree; brlengths=true)
    create_newick(io, firstview(tree.anchor), brlengths=brlengths)
    print(io, ';')

    return nothing
end
