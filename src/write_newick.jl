#TODO: Adapt this code from `RootedTrees`

brlstring(brl::Number) = ':' * string(brl)
brlstring(::Nothing) = ""

"""
This function exists so that the same code in `create_newick` returns a string or prints to an IO (which is much faster), depending on the first argument
"""
_nwkout(o::String, s...) = string(o, s...)
function _nwkout(o::IO, s)
    print(o, s...)

    return o
end

function create_newick(o, p::RNode; brlengths=true)
    nc = outdegree(p)
    if nc > 0
        o = _nwkout(o, '(')
        for (i, c) in enumerate(children(p))
            o = create_newick(o, c; brlengths=brlengths)
            o = i < nc ? _nwkout(o, ',') : o
        end
        o = _nwkout(o, ')')
    end
    o = _nwkout(o, getlabel(p))
    o = brlengths ? _nwkout(o, brlstring(brlength(p))) : o

    return o
end

"""
    newick(node; brlengths=true, fmt=nothing)

Return a Newick string representation of the clade under a `node`. Will not include branch lengths if `brlengths` is set to `false`.
"""
newick(p::RNode; brlengths=true) = create_newick("", p; brlengths=brlengths) * ";"

newick(tree::AbstractTree; brlengths=true) = newick(getroot(tree); brlengths=brlengths)

"""
"""
function print_newick(io::IO, tree::AbstractTree; brlengths=true)
    create_newick(io, getnode(tree, getroot(tree)), brlengths=brlengths)
    print(io, ';')

    return nothing
end
