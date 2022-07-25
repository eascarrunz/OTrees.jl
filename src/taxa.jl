"""
Warning: `Taxon` objects are mutable and should not be used as dictionary keys.
"""
mutable struct Taxon{T<:Union{Symbol,String}}
    id::PhylInt
    name::T
    kind::Symbol

    Taxon(id, name::T, kind = :any) where T = new{T}(id, name, kind)
end

Base.show(io::IO, t::Taxon) = print(io, "Taxon #$(t.id) - $(t.name)")


"""
A `TaxonSet` is an insertion-ordered set of taxa (`Taxon` objects) with unique `String` or `Symbol` names. It is not a taxonomy with a hierarchical structure.
"""
struct TaxonSet{T<:Union{Symbol,String}}
    taxa::Vector{Taxon{T}}
    names::Dict{T,Taxon}

    function TaxonSet(namekeys::Vector{T}, kind = [:any]) where T
        n = length(namekeys)
        taxa = Vector{Taxon{T}}(undef, n)
        for (i, key, k) in zip(1:n, namekeys, Iterators.cycle(kind))
            taxa[i] = Taxon(i, key, k)
        end
        # taxa = Taxon.([(i, x...)... for (i, x) in enumerate(zip(namekeys, kind))])
        # taxa = map(x -> Taxon(x[1], x[2], x[3]), zip(1:lastindex(namekeys), namekeys, kind))
        # taxa = Taxon.(enumerate(namekeys)...)
        namedict = Dict(zip(namekeys, taxa))

        return new{T}(taxa, namedict)
    end
end

Base.length(ts::TaxonSet) = length(ts.taxa)
Base.show(io::IO, ts::TaxonSet) = print(io, "TaxonSet with $(length(ts)) taxa")

Base.getindex(ts::TaxonSet, ind...) = ts.taxa[ind...]
Base.getindex(ts::TaxonSet{T}, keys::T...) where T<:Union{String,Symbol} = ts.names[keys...]


"""
    setname!(taxon_set, taxon, newname)

Change the name of `taxon` in `taxon_set`.

`taxon` can be either a `Taxon` object, a taxon ID, or a taxon name.
"""
function setname!(ts::TaxonSet, taxon::Taxon, v)
    # Let key exceptions happen before altering the `Taxon` object.
    delete!(ts.names, taxon.name)
    ts.names[v] = taxon

    taxon.name = v

    return taxon
end
setname!(ts::TaxonSet, key, v) = setname!(ts, ts[key], v)


function reindex!(ts::TaxonSet, start)
    i = start
    for taxon in ts.taxa[start:end]
        taxon.id = i
        i += 1
    end

    return nothing
end


function Base.delete!(ts::TaxonSet, key)
    id = ts[key].id
    taxname = ts[id].name
    delete!(ts.names, taxname)
    deleteat!(ts.taxa, id)

    reindex!(ts, id)
end


function add!(ts::TaxonSet, namekeys; kind = [:any])
    n0 = length(ts.taxa)
    nnew = length(namekeys)
    idnew = n0 + 1 : n0 + nnew
    sizehint!(ts.taxa, n0 + nnew)
    # taxa = [Taxon(x...) for x in zip(idnew, namekeys, kind)] #TODO: Create taxa in the loop below instead
    # taxa = Taxon.(zip(idnew, namekeys, kind)
    # append!(ts.taxa, taxa)

    for (id, key, k) in zip(idnew, namekeys, Iterators.cycle(kind))
        taxon = Taxon(id, key, k)
        push!(ts.taxa, taxon)
        ts.names[key] = taxon
    end

    return nothing
end
