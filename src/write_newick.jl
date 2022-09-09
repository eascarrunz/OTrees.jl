#TODO: Add writer configurations including support for quoting strings that contain white space.


brlwriter(io::IO, brl::Number) = print(io, ':', string(brl))
brlwriter(::IO, ::Nothing) = nothing


function create_newick_branch(io, vp, brlengths)
    print(io, vp.label)
    brlengths && brlwriter(io, brlength(vp))

    return nothing
end


function create_newick_fork(io, viewlist, brlengths)
    nc = length(viewlist)
    if nc > 0
        print(io, '(')
        for (i, c) in enumerate(viewlist)
            create_newick_fork(io, children(c), brlengths)
            create_newick_branch(io, c, brlengths)
            i < nc && print(io, ',')
        end
        print(io, ')')
    end

    return nothing
end


"""
    write(io, tree[, brlengths = true])
    write(file, tree[, brlengths = true])

Write the Newick representation of a tree (or subtree) to an I/O stream or file.

If a node is given instead of a tree object, the Newick representation will be rooted in that node.
This function can also take a node view, in which case only it will only return the Newick representation corresponding to the subtree rooted in the node view.
"""
function write(io::IO, vp::NodeView; brlengths = true)
    create_newick_fork(io, children(vp), brlengths)
    print(io, vp.label)
    print(io, ';')
    
    return nothing
end


function write(io::IO, node::ONode; brlengths = true)
    root_view = firstview(node)
    create_newick_fork(io, neighbours(root_view), brlengths)
    print(io, root_view.label)
    print(io, ';')

    return nothing
end


write(io::IO, tree::OTree; brlengths = true) =
    write(io, tree.anchor; brlengths = brlengths)


function write(filename::AbstractString, nodeview::NodeView, mode = "w"; brlengths = true)
    open(filename, mode) do f
        write(f, nodeview; brlengths = brlengths)
    end

    return nothing
end


write(filename::AbstractString, node::ONode, mode = "w"; brlengths = true) =
    write(filename, firstview(node), mode; brlengths = brlengths)

write(filename::AbstractString, tree::OTree, mode = "w"; brlengths = true) =
    write(filename, tree.anchor, mode; brlengths = brlengths)

function write(tree; brlengths = true)
    io = IOBuffer()
    write(io, tree; brlengths = brlengths)

    return String(take!(io))
end
