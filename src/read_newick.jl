using OTrees

const NEWICK_DELIM = ('(', ')', ',', ':', ';')
const COMMENT_DELIM = ('[', ']')
const ALL_DELIMS = union(NEWICK_DELIM, COMMENT_DELIM)


function skip_quoted(io)
    chr = peek(io, Char)
    if chr == '\"'
        skipchars(≠('\"'), io)
        skip(io, 1)
    elseif chr == '\''
        skipchars(≠('\''), io)
        skip(io, 1)
    end

    return nothing
end


"""
    analyse_newick(io) -> (N, has_root_length)

Take a stream of a Newick tree and determine the number of nodes and whether the root node has a branch length.
"""
function analyse_newick(io)
    N = 1
    # has_root_length = false
    pos = position(io)
    chr = peek(io, Char)
    while chr ≠ ';'
        chr ∈ ('\"', '\'') && skip_quoted(io)

        N += ((chr == '(') | (chr == ','))
        pos += 1
        seek(io, pos)
        eof(io) && error("the Newick string does not have the terminating character `;`")
        chr = peek(io, Char)
        # has_root_length = (has_root_length | (chr == ':')) * ! (chr == ')')
    end

    return N
end


"""
Read a stream until any character in the target set is found. Return the read characters as a string.
"""
function readuntilany(io, target_set)
    s = IOBuffer()
    chr = peek(io, Char)
    
    while chr ∉ target_set
        print(s, Base.read(io, Char))
        chr = peek(io, Char)
    end

    return String(take!(s))
end


"""
Check that `target` is the current character in a IOStream, and read it. Throw exception if 
it isn't. 
"""
function read_validate(io, target)
    chr = Base.read(io, Char)
    if chr != target
        throw(ErrorException("expected \'$(target)\' but got \'$(chr)\'"))
    end

    return nothing
end


function extract_label(io)
    skipchars(isspace, io)
    chr = peek(io, Char)
    if chr == '\"'
        Base.read(io, Char)            # Read opening quote mark
        s = readuntil(io, '\"')   # Read string
    elseif chr == '\''
        Base.read(io, Char)
        s = readuntil(io, '\'')
    else
        s = readuntilany(io, ALL_DELIMS)
    end

    #! What to do with trailing whitespace?
    
    return s
end


"""
Check whether the next characters describe a comment.
"""
check_comment(io) = peek(io, Char) == '['


function extract_comment(io)
    read_validate(io, '[')
    read_validate(io, '&')
    s = readuntil(io, ']')

    return s
end


"""
Check whether the next characters describe a branch
"""
check_branch(io) = peek(io, Char) == ':'


function parsebranch(io, config)
    read_validate(io, ':')
    s = readuntilany(io, ALL_DELIMS)
    brlength = isempty(s) ?
        config.nobrlen_value : parse(config.brlen_type, s)

    comment_text = check_comment(io) ? extract_comment(io) : ""

    return (brlength = brlength, comment_text = comment_text)
end


struct NewickReaderConfiguration
    brlen_type::Type        # Type of the (valid) branch lengths
    nobrlen_value::Any      # Value to give branch lengths not specified in Newick
    inner_taxa::Bool        # Interpret labels of inner nodes as taxa
    outer_taxa::Bool        # Interpret labels of outer nodes as taxa
end


function parsenode(io, node, config, brlength = true)
    #? Should I also check for comments *before* the node label?
    label           = extract_label(io)
    skipchars(isspace, io)
    comment_text = check_comment(io) ? extract_comment(io) : ""
    skipchars(isspace, io)
    branch =
        check_branch(io) ?
            parsebranch(io, config) : (brlength = config.nobrlen_value, comment_text = "")

    node.label = label
    if brlength
        node.brlength = branch.brlength
    end

    return node
end


function parsefork(io, p, nodesource, i, config)
    read_validate(io, '(')

    skipchars(isspace, io)
    # chr = peek(io, Char)
    i = parsechild(io, p, nodesource, i, config)
    # link!(p, c)
    skipchars(isspace, io)
    # chr = peek(io, Char)

    while peek(io, Char) == ','
        read_validate(io, ',')
        skipchars(isspace, io)
        i = parsechild(io, p, nodesource, i, config)
        # link!(p, c)
        skipchars(isspace, io)
        # chr = peek(io, Char)
    end

    read_validate(io, ')')

    return i, p
end


function parsechild(io, p, nodesource, i, config)
    i += 1
    c = nodesource(i)
    
    link!(p, c)
    
    chr = peek(io, Char)
    chr == '(' && parsefork(io, c, nodesource, i, config)

    parsenode(io, c, config)
    
    return i 
end



function parseroot(io, tree, N, config)
    skipchars(isspace, io)
    comment_text = check_comment(io) ? extract_comment(io) : ""

    root = tree.anchor
    nodesource(i) = tree.nodeviews[2 * i - 3]

    chr = peek(io, Char)
    chr == '(' && parsefork(io, root, nodesource, 1, config)

    parsenode(io, root, config, false)

    read_validate(io, ';')    #TODO: throw an error if the root has a branch length in the Newick string

    return nothing
end


function read(
    io::Union{IO, AbstractString},
    sink::Type{T} = Vector{OTree};
    brlen_type = Float64,
    nobrlen_value = nothing,
    inner_taxa = false,
    outer_taxa = true
    ) where T

    config = NewickReaderConfiguration(
        brlen_type,
        nobrlen_value,
        inner_taxa,
        outer_taxa
    )

    return _read(io, sink, config)
end


_read(s::AbstractString, sink, config) = _read(IOBuffer(s), sink, config)


function _read_one_tree(io, N, config)
    tree = create_tree(N)
    parseroot(io, tree, N, config)

    return tree
end


function _read(io::IO, ::Type{Vector{OTree}}, config)

    trees = OTree[]

    while true
        m = mark(io)
        N = analyse_newick(io)
        # has_root_length && error("branch length for the root is not supported")
        seek(io, m)
        unmark(io)

        tree = _read_one_tree(io, N, config)
        push!(trees, tree)

        eof(io) && break
    end

    return trees
end


function _read(io::IO, ::Type{OTree}, config)
    m = mark(io)
    N = analyse_newick(io)
    seek(io, m)

    tree = _read_one_tree(io, N, config)

    skipchars(isspace, io)
    eof(io) || error("extraneous character \'$(peek(io, Char))\' after the Newick string")

    return tree
end
