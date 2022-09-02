brlwriter(io::IO, brl::Number) = print(io, ':', string(brl))
brlwriter(::IO, ::Nothing) = nothing


function create_newick_fork(io, vp, viewlist; brlengths = true)
    nc = length(viewlist)
    if nc > 0
        print(io, '(')
        for (i, c) in enumerate(viewlist)
            create_newick_fork(io, c, children(c); brlengths=brlengths)
            i < nc && print(io, ',')
        end
        print(io, ')')
    end
    print(io, vp.node.label)
    brlengths && brlwriter(io, brlength(vp))

    return nothing
end





function write(io::IO, vp::NodeView; brlengths = true)
    create_newick_fork(io, vp, children(vp); brlengths = brlengths)
    print(io, ';')

    return io
end

write(io::IO, node::ONode; brlengths = true) =
    write(io, firstview(node); brlengths = brlengths)

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

function newick_string(tree; brlengths = true)
    io = IOBuffer()
    write(io, tree; brlengths = brlengths)

    return String(take!(io))
end
